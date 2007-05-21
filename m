From: "cyril.lacabanne" <cyril.lacabanne@bull.net>
Subject: RPC and TI-RPC Tests Suite
Date: Mon, 21 May 2007 17:34:16 +0200
Message-ID: <4651BBF8.4040008@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: ltp-list@lists.sourceforge.net, nfs@lists.sourceforge.net,
	libtirpc-devel@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <ltp-list-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=ltp-list>
List-Post: <mailto:ltp-list@lists.sourceforge.net>
List-Help: <mailto:ltp-list-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/ltp-list>,
	<mailto:ltp-list-request@lists.sourceforge.net?subject=subscribe>
Sender: ltp-list-bounces@lists.sourceforge.net
Errors-To: ltp-list-bounces@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

Hi,

I'm a student working at Bull France labs. I'm writing a RPC and TI-RPC
tests suite for Linux (but the code is probably independent of the
Operating System). Here is the design of the test suite.

Since NFS does make use of RPC and TI-RPC (for IPv6 now), this test
suite is aimed to guarantee that the underlying RPC/TI-RPC technology is
robust and reliable. It should also help improving the quality of Linux.

Please visit our project web page for more information and find design 
documents at http://nfsv4.bullopensource.org/doc/rpc_testsuite.php

Design documents are :
* title       : Test Plan
  file name   : TestPlan_v12.pdf
  explanation : Following IEEE 829-1998 rules, this documents gives full 
explanation about:
                   - how to use the tests suite
                   - what is tested (such as functions, domains)
                   - which environment is required/needed (software, 
hardware)
  comments    : version 1.2 (2007-05-15), 10 pages
 
* title       : Test Design
  file name   : TestDesign_v13.pdf
  explanation : This document defines:
                   - test requirements,
                   - test dependencies,
                   - test case description,
                   - expected results.
  comments    : version 1.3 (2007-05-15), 138 pages

I have already started writing the test suite code.
Feel free to send your remarks and comments about the design of the test
suite !

Regards,

Cyril Lacabanne

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
