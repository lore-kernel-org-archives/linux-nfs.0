From: "didier ." <did447@gmail.com>
Subject: [patch] configure.in, wrong test for gethostbyname and libnsl
Date: Mon, 4 Sep 2006 02:46:43 +0200
Message-ID: <eba800c90609031746n3beeb198hac560de8753b2db@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_86890_2688805.1157330803075"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GK2bt-0007aZ-57
	for nfs@lists.sourceforge.net; Sun, 03 Sep 2006 17:46:45 -0700
Received: from wx-out-0506.google.com ([66.249.82.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GK2bt-0002ls-IR
	for nfs@lists.sourceforge.net; Sun, 03 Sep 2006 17:46:46 -0700
Received: by wx-out-0506.google.com with SMTP id r21so1885652wxc
	for <nfs@lists.sourceforge.net>; Sun, 03 Sep 2006 17:46:43 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

------=_Part_86890_2688805.1157330803075
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

On a glibc system gethostbyname is in libc not libnsl

In the great autoconf tradition the patch is a copy and past from ethereal

Didier

------=_Part_86890_2688805.1157330803075
Content-Type: text/x-patch; name=configure.in.diff; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ero3to7d
Content-Disposition: attachment; filename="configure.in.diff"

LS0tIGNvbmZpZ3VyZS5pbi5vcmlnCTIwMDYtMDktMDQgMDE6MzY6MDguMDAwMDAwMDAwICswMjAw
CisrKyBjb25maWd1cmUuaW4JMjAwNi0wOS0wNCAwMTo1NzozNi4wMDAwMDAwMDAgKzAyMDAKQEAg
LTE0Nyw4ICsxNDcsMTMgQEAKIGRubCAqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKioqKioqKioqKioqCiBkbmwgKiBDaGVjayBmb3IgcmVxdWlyZWQgbGli
cmFyaWVzCiBkbmwgKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioqKioq
KioqKioqKioqKioqKioqKgotQUNfQ0hFQ0tfTElCKHNvY2tldCwgbWFpbiwgW0xJQlNPQ0tFVD0i
LWxuc2wiXSkKLUFDX0NIRUNLX0xJQihuc2wsIG1haW4sCVtMSUJOU0w9Ii1sbnNsIl0pCitBQ19D
SEVDS19GVU5DKGdldGhvc3RieW5hbWUsICwgW0FDX0NIRUNLX0xJQihuc2wsIGdldGhvc3RieW5h
bWUsIFtMSUJOU0w9Ii1sbnNsIl0pXSkKK0FDX1NVQlNUKExJQk5TTCkKKworQUNfQ0hFQ0tfRlVO
Qyhjb25uZWN0LCAsIAorICAgICAgQUNfQ0hFQ0tfTElCKHNvY2tldCwgY29ubmVjdCwgW0xJQlNP
Q0tFVD0iLWxzb2NrZXQiXSwKKyAgICAgICAgICAgICAgICBBQ19NU0dfRVJST1IoRnVuY3Rpb24g
J3NvY2tldCcgbm90IGZvdW5kLiksICRMSUJOU0wpKQorCiBBQ19DSEVDS19MSUIoY3J5cHQsIGNy
eXB0LCBbTElCQ1JZUFQ9Ii1sY3J5cHQiXSkKIGlmIHRlc3QgIiRlbmFibGVfbmZzdjQiID0geWVz
OyB0aGVuCiAgICAgQUNfQ0hFQ0tfTElCKGV2ZW50LCBldmVudF9kaXNwYXRjaCwgW2xpYmV2ZW50
PTFdLCBBQ19NU0dfRVJST1IoW2xpYmV2ZW50IG5lZWRlZCBmb3IgbmZzdjQgc3VwcG9ydF0pKQpA
QCAtMTcyLDcgKzE3Nyw2IEBACiAgICAgQUNfQ0hFQ0tfTElCKGJzZCwgZGFlbW9uLCBbTElCQlNE
PSItbGJzZCJdKQogZmkKIEFDX1NVQlNUKExJQlNPQ0tFVCkKLUFDX1NVQlNUKExJQk5TTCkKIEFD
X1NVQlNUKExJQkNSWVBUKQogQUNfU1VCU1QoTElCQlNEKQogCg==
------=_Part_86890_2688805.1157330803075
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
------=_Part_86890_2688805.1157330803075
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

------=_Part_86890_2688805.1157330803075--
