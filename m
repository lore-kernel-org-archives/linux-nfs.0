From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Mount version older than kernel: 4 vs. 6
Date: Wed, 04 Aug 2004 14:50:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4110DB81.4020103@bio.ifi.lmu.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsLDh-0001Xq-3b
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 05:50:13 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BsLDg-0002KK-L5
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 05:50:13 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 74843435BB
	for <nfs@lists.sourceforge.net>; Wed,  4 Aug 2004 14:50:10 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 6E677435BA
	for <nfs@lists.sourceforge.net>; Wed,  4 Aug 2004 14:50:10 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

using kernel 2.6.8rc3 and util-linux-2.12a, I ran into those "mount
version older than kernel" messages, which were discussed here for the
2.6.4 kernel before. Patching inode.c, I can see that NFS_MOUNT_VERSION
is 6, while data->version is 4. (The only mount at all that does not
complain is the one done by nfsroot (of course) :-))

Just a stupid question: why does the nfsmount.h from the kernel source
define NFS_MOUNT_VERSION 6? Shouldn't this number match the latest nfs
version, i.e., 4? I've never heard of nfs v6 yet :-)
Or is the meaning of NFS_MOUNT_VERSION different?

Would it be safe to patch nfsmount.h and set the number to 4 for my
own kernel to get rid of this warning, or could that break sth. else?
It just fills my logs and I want to get rid of it...



cu,
Frank

-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *


-------------------------------------------------------
This SF.Net email is sponsored by OSTG. Have you noticed the changes on
Linux.com, ITManagersJournal and NewsForge in the past few weeks? Now,
one more big change to announce. We are now OSTG- Open Source Technology
Group. Come see the changes on the new OSTG site. www.ostg.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
