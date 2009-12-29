From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/2] nfs-utils: add initial tests for statd that run via "make check"
Date: Tue, 29 Dec 2009 10:38:38 -0500
Message-ID: <B5BBFA5F-8B83-4AB2-A4CB-F9D315562434@oracle.com>
References: <1260992440-8234-1-git-send-email-jlayton@redhat.com> <1260992440-8234-3-git-send-email-jlayton@redhat.com> <4B336C25.7000705@RedHat.com> <20091224192007.217a9ed5@tupile.poochiereds.net>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:36078 "EHLO
	rcsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753402AbZL2PkL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Dec 2009 10:40:11 -0500
In-Reply-To: <20091224192007.217a9ed5-PC62bkCOHzGdMjc06nkz3ljfA9RmPOcC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Dec 24, 2009, at 7:20 PM, Jeff Layton wrote:
> On Thu, 24 Dec 2009 08:27:01 -0500
> Steve Dickson <SteveD@redhat.com> wrote:
>
>> On 12/16/2009 02:40 PM, Jeff Layton wrote:
>>> Leverage the support that automake already has for running tests via
>>> make check. Add a simple test that just checks that the statd mon  
>>> and
>>> unmon calls actually work.
>>>
>>> Adding more tests should be a simple matter of adding new scripts
>>> exit 0 on success and non-zero on fail, and adding those to the
>>> Makefile.am.
>>>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> tests/Makefile.am                    |    2 +
>>> tests/t0001-statd-basic-mon-unmon.sh |   55 +++++++++++++++++++++++ 
>>> +++++++++++
>>> tests/test-lib.sh                    |   41 +++++++++++++++++++++++ 
>>> ++
>>> 3 files changed, 98 insertions(+), 0 deletions(-)
>>> create mode 100755 tests/t0001-statd-basic-mon-unmon.sh
>>> create mode 100755 tests/test-lib.sh
>>>
>>> diff --git a/tests/Makefile.am b/tests/Makefile.am
>>> index 997ac51..634fb7b 100644
>>> --- a/tests/Makefile.am
>>> +++ b/tests/Makefile.am
>>> @@ -3,3 +3,5 @@
>>> SUBDIRS = statdtest
>>>
>>> MAINTAINERCLEANFILES = Makefile.in
>>> +
>>> +TESTS = t0001-statd-basic-mon-unmon.sh
>>> diff --git a/tests/t0001-statd-basic-mon-unmon.sh b/tests/t0001- 
>>> statd-basic-mon-unmon.sh
>>> new file mode 100755
>>> index 0000000..d5dffc5
>>> --- /dev/null
>>> +++ b/tests/t0001-statd-basic-mon-unmon.sh
>>> @@ -0,0 +1,55 @@
>>> +#!/bin/bash
>>> +#
>>> +# statd_basic_mon_unmon -- test basic mon/unmon functionality  
>>> with statd
>>> +#
>>> +# Copyright (C) 2009  Red Hat, Jeff Layton <jlayton@redhat.com>
>>> +#
>>> +# This program is free software; you can redistribute it and/or
>>> +# modify it under the terms of the GNU General Public License
>>> +# as published by the Free Software Foundation; either version 2
>>> +# of the License, or (at your option) any later version.
>>> +#
>>> +# This program is distributed in the hope that it will be useful,
>>> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> +# GNU General Public License for more details.
>>> +#
>>> +# You should have received a copy of the GNU General Public License
>>> +# along with this program; if not, write to the Free Software  
>>> Foundation, Inc.,
>>> +# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
>>> +#
>>> +
>>> +. ./test-lib.sh
>>> +
>>> +start_statd
>>> +if [ $? -ne 0 ]; then
>>> +	echo "FAIL: problem starting statd"
>>> +	exit 1
>>> +fi
>>> +
>>> +COOKIE=`echo $$ | md5sum | cut -d' ' -f1`
>>> +MON_NAME=`hostname`
>>> +
>>> +statdtest mon $MON_NAME $COOKIE
>>> +if [ $? -ne 0 ]; then
>>> +	echo "FAIL: mon failed"
>>> +	kill_statd
>>> +	exit 1
>>> +fi
>>> +
>>> +grep -q $COOKIE /var/lib/nfs/statd/sm/$MON_NAME
>> This is a distro specific path... The default is /var/lib/nfs/sm
>> It would be nice if somehow we could pull in the NFS_STATEDIR define
>> from support/include/config.h file...
>>
>
> Good point. I'll need to think on how we can deal with that. Maybe  
> what
> I should do is add a new "statdtest" command that prints out this
> directory? Unless someone has a better idea, I'll respin this set with
> that change soon.

We'd be better off, I think, if you did this test using calls to  
libnsm.a, rather than naked greps.  You're adding yet another  
invisible and undocumented dependency on the "formal API" that is the  
state directory.  I'd rather see the C API tested here, and then  
deprecate direct accesses over time.

>>> +if [ $? -ne 0 ]; then
>>> +	echo "FAIL: $COOKIE not present in monitor file"
>>> +	kill_statd
>>> +	exit 1
>>> +fi
>>> +
>>> +statdtest unmon $MON_NAME
>>> +if [ $? -ne 0 ]; then
>>> +	echo "FAIL: unmon failed"
>>> +	kill_statd
>>> +	exit 1
>>> +fi
>>> +
>>> +kill_statd
>>> +
>>> diff --git a/tests/test-lib.sh b/tests/test-lib.sh
>>> new file mode 100755
>>> index 0000000..053e46d
>>> --- /dev/null
>>> +++ b/tests/test-lib.sh
>>> @@ -0,0 +1,41 @@
>>> +#!/bin/bash
>>> +#
>>> +# test-lib.sh -- library of functions for nfs-utils tests
>>> +#
>>> +# Copyright (C) 2009  Red Hat, Jeff Layton <jlayton@redhat.com>
>>> +#
>>> +# This program is free software; you can redistribute it and/or
>>> +# modify it under the terms of the GNU General Public License
>>> +# as published by the Free Software Foundation; either version 2
>>> +# of the License, or (at your option) any later version.
>>> +#
>>> +# This program is distributed in the hope that it will be useful,
>>> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
>>> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>>> +# GNU General Public License for more details.
>>> +#
>>> +# You should have received a copy of the GNU General Public License
>>> +# along with this program; if not, write to the Free Software  
>>> Foundation, Inc.,
>>> +# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
>>> +#
>>> +
>>> +export PATH=$PATH:$srcdir/statdtest
>>> +
>>> +lockd_registered() {
>>> +	rpcinfo -p | grep -q nlockmgr
>>> +	return $?
>>> +}
>>> +
>>> +start_statd() {
>>> +	rpcinfo -u 127.0.0.1 status 1 &> /dev/null
>>> +	if [ $? -eq 0 ]; then
>>> +		echo "***ERROR***: statd is already running and should "
>>> +		echo "             be down when starting this test"
>>> +		return 1
>>> +	fi
>>> +	$srcdir/../utils/statd/statd --no-notify
>> the $srcdir variable is not define so the script fails
>> right out of the box... So maybe something like this...
>> Initialize srcdir=`dirname $PWD`
>> then '$srcdir/utils/statd/statd --no-notify' will work.
>>
>
> This script is run via "make check". Automake or autoconf (I forget
> which) set $srcdir. There's no need to redefine it here.
>
>>> +}
>>> +
>>> +kill_statd() {
>>> +	kill `cat /var/run/rpc.statd.pid`
>>> +}
>>
>> Overall I like the idea of having a test harness... but I have
>> to wonder if we start building the harness in shell scripts
>> if we are not limiting things right out of the box...
>>
>> Maybe we should consider doing the harness in a more up to date
>> scripting languages like perl or python or even java... Granted
>> I'm not as familiar (or comfortable) with those languages as with
>> shell scripting. Plus its not clear what type of dependencies that
>> would added to the core nfs-utils code, but we should at least
>> think about using a language that might give us more
>> possibilities down the road... Who knowns, in the end, shell  
>> scripting
>> might be the best way to go...
>>
>
> One of the nice things about this "test harness" is that it's pretty
> minimalistic. You can write tests in whatever you like as long as it
> can be run from the makefile. While this test is written as a shell
> script, the bulk of the test is a C program (statdtest.c).
>
> I have no objection to writing tests in something else, but that does
> add additional dependencies. There's something to be said for not
> adding those unless they're really needed.
>
> Thanks for the review so far,
> -- 
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




