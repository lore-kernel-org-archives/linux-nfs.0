From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 4/4] nfs-utils: add initial tests for statd that run
	via "make check"
Date: Fri, 8 Jan 2010 11:59:03 -0500
Message-ID: <20100108165903.GA14172@fieldses.org>
References: <1262962563-5554-1-git-send-email-jlayton@redhat.com> <1262962563-5554-5-git-send-email-jlayton@redhat.com> <70DEDD50-4AC5-4377-B5FA-A1FBCD92EBF3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41896 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751818Ab0AHQ6L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jan 2010 11:58:11 -0500
In-Reply-To: <70DEDD50-4AC5-4377-B5FA-A1FBCD92EBF3@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 08, 2010 at 11:49:16AM -0500, Chuck Lever wrote:
>
> On Jan 8, 2010, at 9:56 AM, Jeff Layton wrote:
>
>> Leverage the support that automake already has for running tests via
>> make check. Add a simple test that just checks that the statd mon and
>> unmon calls actually work.
>>
>> Adding more tests should be a simple matter of adding new scripts
>> exit 0 on success and non-zero on fail, and adding those to the
>> Makefile.am.
>>
>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>> ---
>> tests/Makefile.am                    |    2 +
>> tests/t0001-statd-basic-mon-unmon.sh |   58 +++++++++++++++++++++++++ 
>> +++++++
>> tests/test-lib.sh                    |   60 +++++++++++++++++++++++++ 
>> +++++++++
>> 3 files changed, 120 insertions(+), 0 deletions(-)
>> create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
>> create mode 100755 tests/test-lib.sh
>>
>> diff --git a/tests/Makefile.am b/tests/Makefile.am
>> index a20b42b..faa8197 100644
>> --- a/tests/Makefile.am
>> +++ b/tests/Makefile.am
>> @@ -9,3 +9,5 @@ statdb_dump_LDADD = ../support/nfs/libnfs.a \
>> SUBDIRS = nsm_client
>>
>> MAINTAINERCLEANFILES = Makefile.in
>> +
>> +TESTS = t0001-statd-basic-mon-unmon.sh
>> diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001- 
>> statd-basic-mon-unmon.sh
>> new file mode 100755
>> index 0000000..00127fb
>> --- /dev/null
>> +++ b/tests/t0001-statd-basic-mon-unmon.sh
>> @@ -0,0 +1,58 @@
>> +#!/bin/bash
>> +#
>> +# statd_basic_mon_unmon -- test basic mon/unmon functionality with  
>> statd
>> +#
>> +# Copyright (C) 2010  Red Hat, Jeff Layton <jlayton@redhat.com>
>> +#
>> +# This program is free software; you can redistribute it and/or
>> +# modify it under the terms of the GNU General Public License
>> +# as published by the Free Software Foundation; either version 2
>> +# of the License, or (at your option) any later version.
>> +#
>> +# This program is distributed in the hope that it will be useful,
>> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
>> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> +# GNU General Public License for more details.
>> +#
>> +# You should have received a copy of the GNU General Public License
>> +# along with this program; if not, write to the Free Software  
>> Foundation, Inc.,
>> +# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
>> +#
>> +
>> +. ./test-lib.sh
>> +
>> +# This test needs root privileges
>> +check_root
>> +
>> +start_statd
>> +if [ $? -ne 0 ]; then
>> +	echo "FAIL: problem starting statd"
>> +	exit 1
>> +fi
>> +
>> +COOKIE=`echo $$ | md5sum | cut -d' ' -f1`
>> +MON_NAME=`hostname`
>> +
>> +nsm_client mon $MON_NAME $COOKIE
>> +if [ $? -ne 0 ]; then
>> +	echo "FAIL: mon failed"
>> +	kill_statd
>> +	exit 1
>> +fi
>> +
>> +statdb_dump | grep $MON_NAME | grep -q $COOKIE
>> +if [ $? -ne 0 ]; then
>> +	echo "FAIL: monitor DB doesn't seem to contain entry"
>> +	kill_statd
>> +	exit 1
>> +fi
>> +
>> +nsm_client unmon $MON_NAME
>> +if [ $? -ne 0 ]; then
>> +	echo "FAIL: unmon failed"
>> +	kill_statd
>> +	exit 1
>> +fi
>> +
>> +kill_statd
>> +
>> diff --git a/tests/test-lib.sh b/tests/test-lib.sh
>> new file mode 100755
>> index 0000000..3d47264
>> --- /dev/null
>> +++ b/tests/test-lib.sh
>> @@ -0,0 +1,60 @@
>> +#!/bin/bash
>> +#
>> +# test-lib.sh -- library of functions for nfs-utils tests
>> +#
>> +# Copyright (C) 2010  Red Hat, Jeff Layton <jlayton@redhat.com>
>> +#
>> +# This program is free software; you can redistribute it and/or
>> +# modify it under the terms of the GNU General Public License
>> +# as published by the Free Software Foundation; either version 2
>> +# of the License, or (at your option) any later version.
>> +#
>> +# This program is distributed in the hope that it will be useful,
>> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
>> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>> +# GNU General Public License for more details.
>> +#
>> +# You should have received a copy of the GNU General Public License
>> +# along with this program; if not, write to the Free Software  
>> Foundation, Inc.,
>> +# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
>> +#
>> +
>> +# make sure $srcdir is set and sanity check it
>> +srcdir=${srcdir-.}
>> +if [ ! -d ${srcdir} ]; then
>> +	echo "***ERROR***: bad installation -- \$srcdir=${srcdir}"
>> +	exit 1
>> +fi
>> +
>> +export PATH=$PATH:${srcdir}:${srcdir}/nsm_client
>> +
>> +# Some tests require root privileges. Check for them and skip the  
>> test (exit 77)
>> +# if the caller doesn't have them.
>> +check_root() {
>> +	if [ $EUID -ne 0 ]; then
>> +		echo "*** Skipping this test as it requires root privs ***"
>> +		exit 77
>> +	fi
>> +}
>> +
>> +# is lockd registered as a service?
>> +lockd_registered() {
>> +	rpcinfo -p | grep -q nlockmgr
>> +	return $?
>> +}
>> +
>> +# start up statd
>> +start_statd() {
>> +	rpcinfo -u 127.0.0.1 status 1 &> /dev/null
>> +	if [ $? -eq 0 ]; then
>> +		echo "***ERROR***: statd is already running and should "
>> +		echo "             be down when starting this test"
>> +		return 1
>
> Basically what this tells me is that you can't runs these tests at all  
> if your development tree lives on an NFSv2/3 mount point.

Personally what I'll do is run this on a kvm guest or otherwise
dedicated test machine.  So I can live with that assumption.

--b.
