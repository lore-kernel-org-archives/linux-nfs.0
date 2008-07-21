From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: showmount issues
Date: Mon, 21 Jul 2008 16:08:30 -0400
Message-ID: <18E1FAEB-677F-409D-ABE3-AE8F23F96411@oracle.com>
References: <556445368AFA1C438794ABDA8901891C09193BE1@USA0300MS03.na.xerox.net>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
	martyleisner@yahoo.com, Steve Dickson <SteveD@redhat.com>,
	Neil Brown <neilb@suse.de>
To: "Leisner, Martin" <Martin.Leisner-Y/v6x+lg+nkAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:62437 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbYGUUKf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2008 16:10:35 -0400
In-Reply-To: <556445368AFA1C438794ABDA8901891C09193BE1-Ji2iP3vdqghrBKYPBwKYhw99oQ+liPgx@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Martin-

On Jul 17, 2008, at 6:01 PM, Leisner, Martin wrote:
> I have a system (which is using the legacy SUN derived rpcbind).
>
> For some reason, showmount wasn't "always" working.   It reported
> nothing when running from the command line, but worked under strace
> (ugh!)
>
> I was running fedora8 (showmount 1.1.0).
> I built nfs-utils 1.1.2 -- same problems.
>
> (I just tried a 1.0.6 on a RedHat Enterprise Linux 3 -- it worked  
> fine)
>
> Running the code under gdb, I found some "interesting" problems...
>
> I changed:
> bash2 :2 mleisner@mleisner-linux 05:59:55; rcsdiff -u showmount.c
> ===================================================================
> RCS file: showmount.c,v
> retrieving revision 1.1
> diff -u -r1.1 showmount.c
> --- showmount.c 2008/07/17 21:28:59     1.1
> +++ showmount.c 2008/07/17 21:45:45
> @@ -82,6 +82,8 @@
>  *
>  *  tout contains the timeout.  It will be modified to contain the  
> time
>  *  remaining (i.e. time provided - time elasped).
> + *
> + *    Returns 0 if it works
>  */
> static int connect_nb(int fd, struct sockaddr_in *addr, struct timeval
> *tout)
> {
> @@ -177,7 +179,7 @@
>                tout.tv_sec = TIMEOUT_TCP;
>
>                ret = connect_nb(sock, &saddr, &tout);
> -               if (ret == -1) {
> +               if (ret < 0) {
>                        close(sock);
>                        rpc_createerr.cf_stat = RPC_SYSTEMERROR;
>                        rpc_createerr.cf_error.re_errno = errno;
> @@ -350,7 +352,7 @@
>                                         MOUNTPROG, MOUNTVERS,
> IPPROTO_TCP);
>                if (server_addr.sin_port) {
>                        ret = connect_nb(msock, &server_addr, 0);
> -                       if (ret != -1)
> +                       if (ret == 0)
>                                mclient = clnttcp_create(&server_addr,
>                                                MOUNTPROG, MOUNTVERS,
> &msock,
>                                                0, 0);
>
>
> and now it works....

I think the underlying problem is that sometimes connect_nb() returns  
"-1" to signal an error, and sometimes it returns a negative errno  
type code.

It would be a slightly nicer fix if connect_nb() were changed to  
always return 0 on success and -1 on error.  connect_nb()'s callers do  
not appear to care why it failed, so returning an errno is unnecessary.

Documenting connect_nb()'s return codes (as you did in your patch) is  
a nice finishing touch.

When posting patches, can you also include a patch description and a  
Signed-off-by: line?  Some basic instructions for submitting Linux  
kernel patches can be found here:

http://lxr.linux.no/linux/Documentation/SubmittingPatches

but most of these also apply to submitting to user space packages like  
nfs-utils.

Steve, perhaps this should be included in 1.1.3?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
