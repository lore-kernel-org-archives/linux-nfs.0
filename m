From: Frank Steiner <fsteiner-mail@bio.ifi.lmu.de>
Subject: Re: Mount version older than kernel: 4 vs. 6
Date: Wed, 04 Aug 2004 15:25:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4110E3C3.3050705@bio.ifi.lmu.de>
References: <4110DB81.4020103@bio.ifi.lmu.de> <20040804130419.GI4471@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BsLll-00031J-P7
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 06:25:25 -0700
Received: from acheron.informatik.uni-muenchen.de ([129.187.214.135])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BsLll-0006bv-Bc
	for nfs@lists.sourceforge.net; Wed, 04 Aug 2004 06:25:25 -0700
Received: from internaldeliver.acheron.informatik.uni-muenchen.de (localhost [127.0.0.1])
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 7BB46435BF
	for <nfs@lists.sourceforge.net>; Wed,  4 Aug 2004 15:25:24 +0200 (CEST)
Received: from [141.84.1.141] (galois.bio.ifi.lmu.de [141.84.1.141])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by acheron.informatik.uni-muenchen.de (Postfix) with ESMTP id 6C9A7435BB
	for <nfs@lists.sourceforge.net>; Wed,  4 Aug 2004 15:25:24 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <20040804130419.GI4471@suse.de>
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

Olaf Kirch wrote:
> On Wed, Aug 04, 2004 at 02:50:09PM +0200, Frank Steiner wrote:
> 
>>Just a stupid question: why does the nfsmount.h from the kernel source
>>define NFS_MOUNT_VERSION 6? Shouldn't this number match the latest nfs
>>version, i.e., 4? I've never heard of nfs v6 yet :-)
>>Or is the meaning of NFS_MOUNT_VERSION different?
> 
> 
> That's the version of the NFS kernel mount struct, and is
> absolutely unrelated to the NFS version (except that both
> grow monotonically over time).

I see. But then it looks like a bug to me that the code in the inode.c
is comparing the "NFS version" (4, in data->version) against the
"NFS kernel mount struct" (6, in NFS_MOUNT_VERSION). That doesn't
make sense, does it?

I added this to inode.c
         if (data->version != NFS_MOUNT_VERSION) {
                 printk("nfs warning: mount version %s than kernel\n",
                         data->version < NFS_MOUNT_VERSION ? "older" : "newer");
+                printk("data version: %d\n",data->version);
+                printk("NFS_MOUNT_VERSION: %d\n",NFS_MOUNT_VERSION);


and got this result:
Aug  4 14:33:50 riemann kernel: nfs warning: mmmount version older than kernel
Aug  4 14:33:50 riemann kernel: data version: 4
Aug  4 14:33:50 riemann kernel: NFS_MOUNT_VERSION: 6


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
