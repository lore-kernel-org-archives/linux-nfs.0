From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS][PATCH] Making sure negative lookup entries don't
 exist
Date: Sat, 29 Jan 2005 07:32:11 -0500
Message-ID: <41FB824B.8050601@RedHat.com>
References: <41FA88D5.6010904@RedHat.com> <41FAE1F8.3040307@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: linux-nfs <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CurkL-0001uz-VA
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 04:30:37 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CurkI-000438-Uk
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 04:30:37 -0800
To: Mike Waychison <Michael.Waychison@Sun.COM>
In-Reply-To: <41FAE1F8.3040307@sun.com>
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


Mike Waychison wrote:

>>--- linux-2.4.28/fs/nfs/dir.c.orig	2004-08-07 19:26:06.000000000 -0400
>>+++ linux-2.4.28/fs/nfs/dir.c	2005-01-28 13:00:59.402239000 -0500
>>@@ -455,7 +455,11 @@ int nfs_lookup_verify_inode(struct inode
>>  */
>> static inline int nfs_neg_need_reval(struct inode *dir, struct dentry *dentry)
>> {
>>-	if (!nfs_check_verifier(dir, dentry))
>>+	if (IS_ROOT(dentry))
>>+		return 1;
>>    
>>
>
>I don't think this is needed.  Aren't you guaranteed that a root dentry
>will never have ->d_revalidate called?
>  
>
hmm... I guess I didn't realize this...  but it appear your right....

>  
>
>>+	if (__nfs_revalidate_inode(NFS_SERVER(dir), dir))
>>+		return 1;
>>+	if (time_after(NFS_MTIME_UPDATE(dir), dentry->d_time))
>> 		return 1;
>> 	return time_after(jiffies, dentry->d_time + NFS_ATTRTIMEO(dir));
>> }
>>    
>>
>
>Am I missing something? or doesn't nfs_check_verifier do exactly these
>checks already?
>  
>
nfs_check_verifier() calls nfs_revalidate_inode() which checks the 
attribute cache
before doing the getattr, __nfs_revalidate_inode() just does the getattr

steved.



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
