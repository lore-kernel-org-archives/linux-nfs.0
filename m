From: Jeremy <jeremy@smokehabanos.com>
Subject: Re: Annoying exports problem
Date: Tue, 16 May 2006 23:33:14 -0700
Message-ID: <C09011BA.32978%jeremy@smokehabanos.com>
References: <17514.49131.206204.982852@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FgFa5-0006gK-Jy
	for nfs@lists.sourceforge.net; Tue, 16 May 2006 23:32:25 -0700
Received: from mail.hoofty.com ([216.224.120.253])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FgFa5-0000XQ-CN
	for nfs@lists.sourceforge.net; Tue, 16 May 2006 23:32:25 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17514.49131.206204.982852@cse.unsw.edu.au>
Sender: nfs-admin@lists.sourceforge.net
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




On 5/16/06 11:17 PM, "Neil Brown" <neilb@suse.de> wrote:

> On Tuesday May 16, jeremy@smokehabanos.com wrote:
>> I'm having problems exporting a directory structure and can't figure out
>> why.
>> 
>> Here is the current setup:
>> 
>> /etc/exports:
>> 
>> /space0        *(rw,insecure,no_root_squash,async)
>> /space1        *(rw,insecure,no_root_squash,async)
>> /space2        *(rw,insecure,no_root_squash,async)
>> /space3        *(rw,insecure,no_root_squash,async)
>> /space4        *(rw,insecure,no_root_squash,async)
>> /space5        *(rw,insecure,no_root_squash,async)
>> 
>> Each one of the /space* directories has a subdirectory called images and
>> underneath images is about 600 directories, each with approx 2000 files.
>> Using the above exports, everything is fine.  On the client side I can see
>> the images subdirectory.  The problem is that each client machine needs to
>> mount each one of these /space* partitions separately.  What I'm trying to
>> do is consolidate these mounts points under one directory so I only have to
>> export one instead of 6 mount points.
>> 
>> So what I did on the nfs server is create this structure:
>> 
>>     /storage/space{0,1,2,3,4,5}
>> 
>> So now I have in /etc/exports one line:
>> 
>> /storage    *(rw,insecure,no_root_squash,async)
> 
> Providing you are using 2.6, the crossmnt option should do what you
> want (you also need to ensure that your distro is mounted the 'nfsd'
> directory before starting nfs service).

Is this an export option on the server or a mount option on the client?

I actually got it to work in the little time since my initial post.  The
only way I could do it was to export both the root filesystem and the
individual directories within the /storage.  So it looks like this:

/storage       *(rw,no_root_squash,async)
/storage/space0       *(rw,no_root_squash,async,no_subtree_check,nohide)
/storage/space1       *(rw,no_root_squash,async,no_subtree_check,nohide)
/storage/space2       *(rw,no_root_squash,async,no_subtree_check,nohide)
/storage/space3       *(rw,no_root_squash,async,no_subtree_check,nohide)
/storage/space4       *(rw,no_root_squash,async,no_subtree_check,nohide)
/storage/space5       *(rw,no_root_squash,async,no_subtree_check,nohide)

I achieved the mount point consolidation I was trying to do but I'm just
wondering if there's a cleaner way to do this.  I assume I had to do this
because /storage is on the root filesystem and /storage/space* is on their
own partitions.

Thanks
-jeremy

> 
> If you aren't using 2.6, it is very hard to make this work.
> 
> NeilBrown
> 
>> 
>> The problem is from the client side, when mounting /storage, I can see all
>> the space* subdirectories but I can no longer see the images directory that
>> is underneath.  Ls on /storage/space*/* just shows nothing.
>> 
>> Looked at the nohide options, also the subtree options and neither seemed to
>> make any difference.
>> 
>> Don't understand why.  I figured this was a simple change.
>> 
>> Thanks
>> -jeremy
>> 
>> 
>> 
>> 
>> -------------------------------------------------------
>> Using Tomcat but need to do more? Need to support web services, security?
>> Get stuff done quickly with pre-integrated technology to make your job easier
>> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
>> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> -------------------------------------------------------
> Using Tomcat but need to do more? Need to support web services, security?
> Get stuff done quickly with pre-integrated technology to make your job easier
> Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
> http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
