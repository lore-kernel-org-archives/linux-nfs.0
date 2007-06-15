From: mike <mike503@gmail.com>
Subject: Re: Trying to determine why my NFS connection goes away
Date: Fri, 15 Jun 2007 03:00:12 -0700
Message-ID: <bd9320b30706150300odb27fc6ma3f2e44fa1f2cc59@mail.gmail.com>
References: <bd9320b30706141625l6ceb9c73j22a46cf115ca78cd@mail.gmail.com>
	<1181874951.15174.15.camel@heimdal.trondhjem.org>
	<bd9320b30706142333h539215b4jd3c062c4ed666e8f@mail.gmail.com>
	<200706151141.44300.bs@q-leap.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Bernd Schubert" <bs@q-leap.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz8bD-0008OK-Mc
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 03:00:11 -0700
Received: from nz-out-0506.google.com ([64.233.162.239])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hz8bF-000717-Rp
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 03:00:15 -0700
Received: by nz-out-0506.google.com with SMTP id 18so2287905nzp
	for <nfs@lists.sourceforge.net>; Fri, 15 Jun 2007 03:00:12 -0700 (PDT)
In-Reply-To: <200706151141.44300.bs@q-leap.de>
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

On 6/15/07, Bernd Schubert <bs@q-leap.de> wrote:
> Sure?

well, bad news.

just ran it. i cleared dmesg beforehand. only a minute or so of
nhfsstone already triggered this many errors:

[root@web03 /]# dmesg -c
nfs: server raid01 not responding, still trying
nfs: server raid01 not responding, still trying
nfs: server raid01 not responding, still trying
nfs: server raid01 not responding, still trying
nfs: server raid01 not responding, still trying
nfs: server raid01 not responding, still trying
nfs: server raid01 not responding, still trying
nfs: server raid01 OK
nfs: server raid01 not responding, still trying
nfs: server raid01 OK
nfs: server raid01 OK
nfs: server raid01 OK
nfs: server raid01 OK
nfs: server raid01 OK
nfs: server raid01 OK
nfs: server raid01 OK

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
