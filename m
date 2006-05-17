From: Jeremy <jeremy@smokehabanos.com>
Subject: Re: Annoying exports problem
Date: Wed, 17 May 2006 00:40:36 -0700
Message-ID: <C0902184.33096%jeremy@smokehabanos.com>
References: <17514.50440.625251.136574@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FgGdH-0005fw-UC
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 00:39:47 -0700
Received: from mail.hoofty.com ([216.224.120.253])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1FgGdG-0000lf-Re
	for nfs@lists.sourceforge.net; Wed, 17 May 2006 00:39:48 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17514.50440.625251.136574@cse.unsw.edu.au>
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




On 5/16/06 11:39 PM, "Neil Brown" <neilb@suse.de> wrote:

> On Tuesday May 16, jeremy@smokehabanos.com wrote:
>>> 
>>> Providing you are using 2.6, the crossmnt option should do what you
>>> want (you also need to ensure that your distro is mounted the 'nfsd'
>>> directory before starting nfs service).
>> 
>> Is this an export option on the server or a mount option on the client?
>> 
> 
> export option.
> 
>> I actually got it to work in the little time since my initial post.  The
>> only way I could do it was to export both the root filesystem and the
>> individual directories within the /storage.  So it looks like this:
>> 
>> /storage       *(rw,no_root_squash,async)
>> /storage/space0       *(rw,no_root_squash,async,no_subtree_check,nohide)
>> /storage/space1       *(rw,no_root_squash,async,no_subtree_check,nohide)
>> /storage/space2       *(rw,no_root_squash,async,no_subtree_check,nohide)
>> /storage/space3       *(rw,no_root_squash,async,no_subtree_check,nohide)
>> /storage/space4       *(rw,no_root_squash,async,no_subtree_check,nohide)
>> /storage/space5       *(rw,no_root_squash,async,no_subtree_check,nohide)
> 
> This works too
> Putting 'crossmnt' on the first line should remove the need for the
> remaining lines.
> But if it ain't broke, don't fix it..

Tried the crossmnt option and it didn't seem to work.  It's an older suse
distro, 9.2, but it is 2.6...

Thanks
-jeremy

> NeilBrown




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
