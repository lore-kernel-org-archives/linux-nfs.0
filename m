From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: [PATCH] SVC sockets don't disable Nagle
Date: Wed, 30 Apr 2003 00:42:45 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0304300029360.8473-100000@kenzo.iwr.uni-heidelberg.de>
References: <3EAEF6A7.1000806@austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: trond.myklebust@fys.uio.no, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19AdoU-0001PY-00
	for <nfs@lists.sourceforge.net>; Tue, 29 Apr 2003 15:43:02 -0700
To: Olof Johansson <olof@austin.ibm.com>
In-Reply-To: <3EAEF6A7.1000806@austin.ibm.com>
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

On Tue, 29 Apr 2003, Olof Johansson wrote:

> Below patch disables it on the server side as well. For latency reasons, 
> this should be the desired behaviour NFS at both client and server.

I disagree with this general statement. Nagle is there in the TCP protocol 
for a specific reason and enabling or disabling it gives the opportunity 
to better tune the connection.
It seems like disabling Nagle is the bolierplate answer for anyone who 
encounters GigEth or better networking simply because the TCP protocol was 
not designed for such fast networks. But what happens to others that do 
not have GigEth ? What is the impact of this change for a slower/congested 
network ?
If anything, I would like to see this as a per-mount-point and 
per-export-entry option...

--
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
