From: Tim Pickard <tpickard@crossref.org>
Subject: NFS configuration question
Date: Tue, 06 May 2003 18:53:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <PGEKLHJLLGLFPCINFLBLOEIADJAA.tpickard@crossref.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mta7.algx.net ([67.92.168.236] helo=chimta02.algx.net)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DBCo-0003sl-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 15:46:38 -0700
Received: from TPICKARD
 (ip67-89-23-170.z23-89-67.customer.algx.net [67.89.23.170])
 by chimmx02.algx.net
 (iPlanet Messaging Server 5.2 HotFix 1.10 (built Jan 23 2003))
 with SMTP id <0HEH00JSBLX88G@chimmx02.algx.net> for nfs@lists.sourceforge.net;
 Tue, 06 May 2003 17:46:21 -0500 (CDT)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

I have 3 RedHat8 machines that share a common directory via NFS.

The issue is processes on machines B and C do not get a complete file from
the shared directory on A.

As an example, tail -f file X on B or C.  Cat data to file X on A.  The
process tail does not catch the change.

Directory is exported with following options:
(rw,insecure,sync,no_root_squash)

What am I missing or misconfigured?

Tim Pickard
Systems Support Analyst and Administrator
40 Salem Street
Lynnfield, MA  01940
p.781-295-0072
f.781-295-0077
tpickard@crossref.org





-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
