From: David Rees <dbr@greenhydrant.com>
Subject: Horrible NFS read performance between 2.4.18/19?
Date: Wed, 21 Aug 2002 20:59:16 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020821205915.A2190@greenhydrant.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [208.48.139.185] (helo=forty.greenhydrant.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hj7x-0001on-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 20:59:21 -0700
To: nfs@lists.sourceforge.net
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

Hi,

I've got a number of Linux nfs clients running 2.4.18 with trond's NFS-ALL
patch and a server running 2.4.19 also with the NFS-ALL patch.

The machines are all hooked up to the same switch.

The problem is that using any rsize/wsize combination larger that 2048
results in the nfs clients getting horrible read performance.  The defaults
worked fine with the client/server ran 2.4.18 with the NFS-ALL patch.  I
have not tried updated the clients to 2.4.19, but that is the next step. 
Write performance is fine.

Is this expected behavior?  Or did something change between the two kernels
that would cause this problem?

Thanks,
Dave


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
