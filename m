From: Scott Mcdermott <smcdermott@questra.com>
Subject: Re: (autofs) Re: Direct mounts on Linux
Date: Tue, 21 Jan 2003 01:48:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030121064851.GK10369@questra.com>
References: <15916.14776.460148.770017@lemming.engeast.baynetworks.com> <20030120214134.GE1042@questra.com> <p5vg0jz08z.fsf@lemming.engeast.baynetworks.com> <20030121030851.GG10369@questra.com> <p5wukzyx8m.fsf@lemming.engeast.baynetworks.com> <20030121040318.GI10369@questra.com> <p5r8b7yr4l.fsf@lemming.engeast.baynetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.questra.com ([64.132.48.186])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18asDN-0007dp-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Jan 2003 22:48:53 -0800
Received: from questra.com (hades.roc.questra.com [64.132.48.226])
	by ns1.questra.com (Postfix) with SMTP id BBD35AB5A7
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 01:48:51 -0500 (EST)
To: nfs@lists.sourceforge.net
In-Reply-To: <p5r8b7yr4l.fsf@lemming.engeast.baynetworks.com>
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

Paul Smith on Tue 21/01 01:05 -0500:
>   sm> mostly nowadays, `pwd' is a shell builtin that doesn't use the
>   sm> algorithm you refer to, if I understand right (like /bin/pwd has
>   sm> to use, eg keep going ..) instead keeping track internally.
> 
> Well, sure, but there's still getcwd() ... :)

which is also kept track of in the shell (talking about bash only, don't
know what other shells do)


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
