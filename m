From: Wade Hampton <wade.hampton@nsc1.net>
Subject: Re: df hangs on down nfs server mounted with hard,intr, can't
 kill
Date: Tue, 09 Mar 2004 15:08:54 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <404E2456.4000801@nsc1.net>
References: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0ngL-00054y-Qg
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 12:18:29 -0800
Received: from www.nsc1.net ([4.22.175.200] helo=mail.nsc1.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0n9F-000579-KL
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 11:44:18 -0800
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD25@lavender-fe.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Lever, Charles wrote:

>hi wade-
>
>the fact that "intr" doesn't work as expected is a bug, and
>folks are attempting to address this at least partially in 2.6.
>  
>
Thanks.  While they they are addressing it, it would be nice to have
a means of calling statvfs with a timeout or always have statvfs
interruptable (even if mounted hard w/o intr).

One kernel goal should be to allow someone to lose a mount or USB device,
and still be able to kill any running jobs/modules, but not have to 
reboot the
computer (NFS yesterday on one machine, USB today on another).

>if you want a way to do a "df" without hanging your client,
>try using a soft mount with a short-ish timeout for your
>df requests.
>  
>
I had to go with the hard mount command due to the type of NFS
server I have to access (legacy system).

>caveat:  read the Linux NFS FAQ for more on using "soft" safely.
>  
>
Thanks.  I will. 

Do you think that doing a showmount before doing a df would be
a safe approach for now?

    showmount -e <server>
    if it fails
       return error code
    else
       df <mount point>

Thanks,
--
Wade Hampton


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
