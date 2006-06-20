From: James Pearson <james-p@moving-picture.com>
Subject: 32 bit stat() on a 64 bit kernel failing on a large NFS
	filesystem?
Date: Tue, 20 Jun 2006 12:05:20 +0100
Message-ID: <4497D670.2040900@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fse2v-0000zb-56
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 04:05:25 -0700
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fse2u-0003cL-1O
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 04:05:25 -0700
Received: from minion.mpc.local ([172.16.11.112] helo=moving-picture.com)
	by moving-picture.com with esmtp (Exim 4.43) id 1Fse2q-0001jb-L8
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 12:05:20 +0100
To: NFS List <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I recently found a problem running a 32bit (i686) binary on a 64bit 
(x86_64) kernel that fails when stat'ing any file on a multi-TB NFS 
clustered file system (a non-Linux file system).

stat() returns EOVERFLOW (Value too large for defined data type)

The same 32bit binary running on a 32bit kernel stat'ing the same files 
works OK.

In both cases, I'm using RHEL4 based distros on the clients (I also 
tried a generic 2.6.16.x kernel on the 64 bit client, but that made no 
difference).

We can work round the problem by either making sure the binary is 
compiled with _FILE_OFFSET_BITS set to 64, or configuring the NFS file 
server to use 32 bit 'file IDs'.

My question are:

Is this a 'bug' or 'feature' with using a 32 bit app on a 64 bit kernel?

If it's a 'feature', can anyone explain why it works in this way?

Thanks

James Pearson




_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
