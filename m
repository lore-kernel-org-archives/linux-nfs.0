From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: limit on filesystem size?
Date: Sat, 3 Aug 2002 00:35:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15691.2379.954309.55464@charged.uio.no>
References: <20020801195309.GA26793@stikine.ucs.sfu.ca>
	<shs7kja48km.fsf@charged.uio.no>
	<20020802202210.GA28263@stikine.ucs.sfu.ca>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17al2v-00017N-00
	for <nfs@lists.sourceforge.net>; Fri, 02 Aug 2002 15:37:21 -0700
To: Martin Siegert <siegert@sfu.ca>
In-Reply-To: <20020802202210.GA28263@stikine.ucs.sfu.ca>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

>>>>> " " == Martin Siegert <siegert@sfu.ca> writes:

     > Please, bear with me - I am by no means an expert on these
     > issues.  But my impression was that the problem is in
     > include/linux/blkdev.h

     > struct request { ...
     >         unsigned long sector;

     > with results in a (local) filesystem size limit of 2TB (unless
     > sectors larger than 512 bytes are used).

     > Am I understanding correctly that you are telling me that this
     > does not apply to NFS and that despite this definition I could
     > even reexport (user space NFS?) such a filesystem?

I repeat: yes!

NFS does not know anything about sectors. It indexes *files* by means
of an opaque 32-byte (NFSv2) or 64-byte (v3) filehandle. The latter
can be considered to be the equivalent of 'file descriptors' as used
by libc does in open()/read()/write().

Rexporting filesystems is never a good idea though. Better to allow
all NFS clients direct access to the server...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
