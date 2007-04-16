From: Steve Dickson <SteveD@redhat.com>
Subject: Re: CentOS4.4 support NFSv4 Replication and Migration
Date: Mon, 16 Apr 2007 14:20:32 -0400
Message-ID: <4623BE70.50404@RedHat.com>
References: <003801c77cb1$42e77870$207ba8c0@barcelona>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1637653469=="
Cc: nfs@lists.sourceforge.net
To: Phillip Huang <phuang@plasmon.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HdVoI-0006lu-9w
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 11:20:36 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HdVoK-0006Nw-Fm
	for nfs@lists.sourceforge.net; Mon, 16 Apr 2007 11:20:20 -0700
In-Reply-To: <003801c77cb1$42e77870$207ba8c0@barcelona>
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

--===============1637653469==
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit



Phillip Huang wrote:
> Hi all,
> 
> I have rebuild CentOS4.4 kernel with 2.6.20,
> and its original nfs-util is 1.0.6.
> 
> Does this support NFSv4/replication and migration?
Grab the latest nfs-utils in FC6 (nfs-utils-1.0.10-7.fc6).
It has the support that was tested at this years connectathon..

steved.


--===============1637653469==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============1637653469==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1637653469==--
