From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [patch] fix statd -n
Date: Fri, 02 May 2008 11:21:18 -0400
Message-ID: <481B316E.8090800@gmail.com>
References: <24c1515f0804170938s23fe3ea3pfe77355ed01d8bbf@mail.gmail.com>	 <480902CA.1070805@redhat.com> <48090356.9020703@redhat.com>	 <20080418203225.GD28277@fieldses.org>	 <24c1515f0804181346g5867fa1fqfbbcd13af25027cb@mail.gmail.com>	 <20080421000214.GA5453@fieldses.org>	 <24c1515f0804281352u2d04ac89i820dc6807dde39f1@mail.gmail.com>	 <4817346F.5000101@netapp.com> <20080429161607.GA20420@fieldses.org>	 <24c1515f0805010557o5daf72f7hc3db5bf85354898e@mail.gmail.com> <24c1515f0805010628k6b57598btb27116c719b99fad@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090103050302000901000201"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Peter Staubach <staubach@redhat.com>, linux-nfs@vger.kernel.org
To: Janne Karhunen <janne.karhunen@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64826 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756675AbYEBPTL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 2 May 2008 11:19:11 -0400
In-Reply-To: <24c1515f0805010628k6b57598btb27116c719b99fad-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090103050302000901000201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Janne Karhunen wrote:
> Hi,
>
> So effectively, it makes me sleep better. With it:
> - I can rely on clients identifying the server correctly,
> - I'm not exposing out anything that is not needed,
> - Can tell by the address what this traffic is,
> - Can be sure that packets are sent out via right interface
>
> It might be even better if it would exit if -n is used when
> no such interface is actually available. As I did it, it still
> gambles here just as before.
>
>   

After browsing thru "statd -n" flow, it is still not clear what will 
happen if there are more than 2 interfaces used to export NFS shares ? 

Using "statd -H", together with patches described in:
https://www.redhat.com/archives/cluster-devel/2007-April/msg00028.html ,

our cluster failover (with 4 IP interfaces per server) seemed to run 
well without troubles. Note that 2/3 of the patch in 4-3 can be removed 
*now* since it deals with moving server address from network header into 
lockd internal structures - another similar patch (by Frank van 
Maarseveen) was accepted into mainline kernel after our patch that has 
the required functionality:
http://lkml.org/lkml/2007/7/10/553 .

So the following is our (-H) flow:
* Server dispatches statd with "-N" option that has a user mode script
   (sample program fotest.c enclosed). It is expected the user mode script
   could structure its nlm directory accordingly.
* Upon failover, the take-over server notifies clients with:
   "/usr/sbin/sm-notify -f -v floating_ip_address -P an_sm_directory"

The advantages of "-H" approach over "-n" are (I think ?):
* It can handle multiple NFS export network interfaces.
* It knows which clients coming from which interfaces to allow selective 
grace period for each interface.

In many ways, I would think "-n" should be obsolete ?

-- Wendy

--------------090103050302000901000201
Content-Type: text/x-csrc;
 name="fotest.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fotest.c"

#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <sys/stat.h>      /* for mode_t */

void usage() 
{

	printf("\n");
	printf("    check out \"man rpc.statd\":\n");
	printf("    This callout program should receive callouts for\n");
	printf("    NLM  client  monitor and unmonitor requests. It is\n");
	printf("    run with 3 arguments: \n"); 
	printf("    1st: either add-client or del-client\n");
	printf("    2nd: the name of the client\n");
	printf("    3rd: the name of the server as known to the client.\n");

	return;
}

int main (int argc, char* argv[]) 
{
        char* file = "/tmp/NLM/from-ha";
        mode_t rw_mode;
        int rc, debug=0, i;
	FILE *fd;
        struct flock lock;

        /* Open a file descriptor to the file.  */
        rw_mode = S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH;     /* 0644 */
        fd = fopen(file, "a+");

	fprintf(fd, "%s is invoked with %d arguments.\n", argv[0], argc - 1); 
	if (argc != 4) {
		fprintf (fd, "    error: invalid arguments\n");
		debug = 1;
	}

	for (i = 1; i < argc; ++i) 
		fprintf (fd, "    %s\n", argv[i]); 

	fclose(fd);

	return 0; 
} 


--------------090103050302000901000201--
