From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: (autofs) Re: Direct mounts on Linux
Date: Mon, 20 Jan 2003 23:03:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030121040318.GI10369@questra.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com> <20030120214134.GE1042@questra.com> <p5vg0jz08z.fsf@lemming.engeast.baynetworks.com> <20030121030851.GG10369@questra.com> <p5wukzyx8m.fsf@lemming.engeast.baynetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18apd9-0001jm-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 20:03:19 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id 9CFB3AB784
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 23:03:18 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <p5wukzyx8m.fsf@lemming.engeast.baynetworks.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Paul Smith on Mon 20/01 22:53 -0500:
> Well, if you mount directly in / it can be a big problem, since
> commands like pwd etc. often use an algorithm that can hang if one of
> your direct mounts in / is unavailable.

mostly nowadays, `pwd' is a shell builtin that doesn't use the algorithm
you refer to, if I understand right (like /bin/pwd has to use, eg keep
going ..) instead keeping track internally.

but your point is a good one :)

(if only umount -f worked hehe see recent list archives)


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
