From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: URGENT: Problems with NFS-Root-Clients
Date: Tue, 27 Aug 2002 17:39:58 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0208271736450.18747-100000@kenzo.iwr.uni-heidelberg.de>
References: <95AF67BA7F70D511829B0002A551737001C9C2@faw-e01.faw.freudenberg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jiRo-0003GC-00
	for <nfs@lists.sourceforge.net>; Tue, 27 Aug 2002 08:40:04 -0700
To: Marco.Schwarz@Freudenberg.de
In-Reply-To: <95AF67BA7F70D511829B0002A551737001C9C2@faw-e01.faw.freudenberg.de>
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

On Tue, 27 Aug 2002 Marco.Schwarz@Freudenberg.de wrote:

> NET4: Unix domain sockets 1.0/SMP for Linux NET4.0

What are the lines just before this one ? Some network driver should be 
initialized there, provided that you selected it for compilation into the 
kernel (you did, didn't you ?)

> Root-NFS: Server returned error -5 while mounting /netclients/192.168.0.87

The whole thing seems to me like there is no network connectivity.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
