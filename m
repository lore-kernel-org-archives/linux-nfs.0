From: ed@sam-solutions.net (Ed V. Bartosh)
Subject: Re: NFSv3 UID/GID mapping
Date: Fri, 23 Apr 2004 12:12:05 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <m3ekqfvz16.fsf@pc213.belcaf.minsk.by>
References: <m3vfjsxsky.fsf@pc213.belcaf.minsk.by>
	<20040422172512.GE12400@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGwlg-0004qe-8t
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 02:14:44 -0700
Received: from mail.sam-solutions.net ([217.21.35.41])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BGwlb-0007dp-T7
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 02:14:43 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20040422172512.GE12400@fieldses.org> (J. Bruce Fields's
 message of "Thu, 22 Apr 2004 13:25:12 -0400")
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

"J. Bruce Fields" <bfields@fieldses.org> writes:

> On Thu, Apr 22, 2004 at 12:36:13PM +0300, Ed V. Bartosh wrote:
>> Here is the NFSv3 uid/gid mapping implementation (both kernel and
>> nfs-utils parts). Userspace part uses idmap daemon from CITI NFSv4, 
>> so the NFSv4 patches are required.
>
> Just out of curiosity:
> 	* This does the server side only.  Have you looked at the client side
> 	  at all?
No. It's just a server-side mapping. I think we don't need to rely on
client for that. There are many other possibilities to change uids on
client side. Also client-based solution is less secure than
server-side one and also it's the linux-only solution.

> 	* What sort of applications are you considering for this?
>
I'm considering that this should be used in cases when there is no
possibility to have equal uids on the NFS server and client. For
example we have this situation when we use the same share as SMB and
NFS share and we have to map uids of NFS users to uids of samba users 
(preferable windows boxes). In our situation this mapping is 
required because we need server XFS ACLs to work properly for any type
of clients.
I think there are many other situations when it may be useful to use
this kind of mapping.

>> Look at this, please. Any kind of feedback will be appreciated.
>
> Do you also need to do map the id's in nfs3xdr.c:xdr_encode_setattr() and
> xdr_decode_fattr()?
Yes, I do. Thank you.

> Is IDMAP_UID_NONE really needed, or could you just use an ENOENT return?
>
It's not important, i think, because '(uid_t) -1' is already used in
auth.c, I've just named it. But, yes, it can be used partly. I mean that
uids which can't be mapped will be passed from userspace in any
case and we'll need to check it somewhere.

> We need to figure out a way to do this without duplicating so much code
> from nfs4idmap.c.
Yes, we need it, but it's not too much code. I think that there is
sense to move only deferred request handling functions somewhere in
separate file and use it from nfs4 and nfs3 idmap functions.

> Also note some of that code is wrong.  (See the nfsd_idmap patches in
> http://www.citi.umich.edu/projects/nfsv4/linux/kernel-patches/2.6.6-rc1-3/).
>
Yes, sure. When I worked on this patches there where only CITI patches
for 2.6.5 available. I used them for my work.

Thank you for your feedback.
I'll change the code according to your suggestions.

BTW, Is any chance for this functionality to be in mainstream 
sometime ?

-- 
Best regards,
Ed V. Bartosh


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
