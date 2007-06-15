From: Bernd Schubert <bs@q-leap.de>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Fri, 15 Jun 2007 11:41:44 +0200
Message-ID: <200706151141.44300.bs@q-leap.de>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz8JO-0006NH-NT
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 02:41:46 -0700
Received: from ns1.q-leap.de ([153.94.51.193] helo=mail.q-leap.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hz8JQ-0001Vw-MK
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 02:41:50 -0700
Received: from lanczos (lanczos [192.168.55.86])
	by mail.q-leap.de (Postfix) with ESMTP id D3D964603
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 11:41:44 +0200 (CEST)
In-Reply-To: <bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Friday 15 June 2007 08:33:17 mike wrote:
> no - if you look at the mount parameters i am explicitly stating TCP.

Sure?

On Friday 15 June 2007 01:25:31 mike wrote:
> THE SPECS:
>
> Client mounts server:
> raid01:/home on /local/home type nfs
> (rw,noatime,nfsvers=3,rsize=16384,wsize=16384,hard,intr,timeo=10,addr=192.1
>68.1.151)
>

I don't see tcp here.


Cheers,
Bernd

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
