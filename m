From: Bernd Schubert <bernd-schubert@gmx.de>
Subject: Re: 32 bit stat() on a 64 bit kernel failing on a large NFS
	filesystem?
Date: Tue, 20 Jun 2006 13:30:09 +0200
Message-ID: <200606201330.09563.bernd-schubert@gmx.de>
References: <4497D670.2040900@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FseQA-0003An-S2
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 04:29:26 -0700
Received: from mail.gmx.net ([213.165.64.21])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1FseQA-0001xB-CL
	for nfs@lists.sourceforge.net; Tue, 20 Jun 2006 04:29:27 -0700
To: nfs@lists.sourceforge.net,
	James Pearson <james-p@moving-picture.com>
In-Reply-To: <4497D670.2040900@moving-picture.com>
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

On Tuesday 20 June 2006 13:05, James Pearson wrote:
> I recently found a problem running a 32bit (i686) binary on a 64bit
> (x86_64) kernel that fails when stat'ing any file on a multi-TB NFS
> clustered file system (a non-Linux file system).
>
> stat() returns EOVERFLOW (Value too large for defined data type)
>
> The same 32bit binary running on a 32bit kernel stat'ing the same files
> works OK.
>
> In both cases, I'm using RHEL4 based distros on the clients (I also
> tried a generic 2.6.16.x kernel on the 64 bit client, but that made no
> difference).
>
> We can work round the problem by either making sure the binary is
> compiled with _FILE_OFFSET_BITS set to 64, or configuring the NFS file
> server to use 32 bit 'file IDs'.
>
> My question are:
>
> Is this a 'bug' or 'feature' with using a 32 bit app on a 64 bit kernel?
>
> If it's a 'feature', can anyone explain why it works in this way?

I already had the same problem, just see this thread:

http://lkml.org/lkml/2005/2/28/172

-- =

Bernd Schubert
PCI / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
