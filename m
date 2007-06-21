From: Chuck Lever <chuck.lever@oracle.com>
Subject: NFS debugging helpers
Date: Thu, 21 Jun 2007 16:31:29 -0400
Message-ID: <467AE021.4000307@oracle.com>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------080401060502040901070404"
To: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I1TKh-0002eU-6t
	for nfs@lists.sourceforge.net; Thu, 21 Jun 2007 13:32:53 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I1TKk-0000k5-2G
	for nfs@lists.sourceforge.net; Thu, 21 Jun 2007 13:32:50 -0700
Received: from rgmgw1.us.oracle.com (rgmgw1.us.oracle.com [138.1.186.110])
	by rgminet01.oracle.com (Switch-3.2.4/Switch-3.1.6) with ESMTP id
	l5LKWfeA018871
	for <nfs@lists.sourceforge.net>; Thu, 21 Jun 2007 14:32:41 -0600
Received: from acsmt350.oracle.com (acsmt350.oracle.com [141.146.40.150])
	by rgmgw1.us.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id
	l5LHo1mG025928
	for <nfs@lists.sourceforge.net>; Thu, 21 Jun 2007 14:32:41 -0600
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

This is a multi-part message in MIME format.
--------------080401060502040901070404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I thought I remembered that nfs-utils has simple programs to set NFS/RPC 
debugging flags, but I couldn't find them.

So I constructed a couple of Python scripts to remember the flag names 
and values (see attached).  They are still a little raw.

Is there anything like this already out there?

--------------080401060502040901070404
Content-Type: text/plain;
 name="nfsdebug"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfsdebug"

#!/usr/bin/env python
# -*- python-mode -*-
"""Script to set NFS debug levels symbolically
"""

__copyright__ = """
Copyright (C) 2007, Chuck Lever <chuck.lever@oracle.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
"""

""" History:
Thu Jun 21 10:41:40 EDT 2007 cel - created
"""

import sys, os, time, popen2

""" From include/linux/nfs_fs.h
"""
NfsDebugFlags = {
    'vfs'         : 0x0001,
    'dircache'    : 0x0002,
    'lookupcache' : 0x0004,
    'pagecache'   : 0x0008,
    'proc'        : 0x0010,
    'xdr'         : 0x0020,
    'file'        : 0x0040,
    'root'        : 0x0080,
    'callback'    : 0x0100,
    'client'      : 0x0200,
    'mount'       : 0x0400,
}

NoNfsFlags = 0
AllNfsFlags = 0x07ff

def DoCmd(cmd):
    p = popen2.Popen3(cmd, True)
    output = p.fromchild.read()
    if p.wait():
        print '%s failed (%s)' % (str(cmd), p.childerr.read().strip())
    return output

def CurrentSetting():
    string = DoCmd("/sbin/sysctl sunrpc.nfs_debug")
    words = string.split()
    return int(words[2])

def SetNfsFlags(flags):
    cmd = '/usr/bin/sudo /sbin/sysctl -w sunrpc.nfs_debug=%d' % flags
    DoCmd(cmd)
    return

def ProcessFlag(flag):
    if flag not in NfsDebugFlags:
        print 'Unrecognized NFS debugging flag.'
        return

    current = CurrentSetting()
    SetNfsFlags(current | NfsDebugFlags[flag])

    return


#
# Main
#

if len(sys.argv) == 1:
    current = CurrentSetting()
    if current == NoNfsFlags:
        print 'NFS debugging is currently disabled.'
    elif current == AllNfsFlags:
        print 'NFS debugging is currently fully enabled.'
    else:
        print 'Current NFS debugging flags:'
        for i in NfsDebugFlags.items():
            if (current & i[1]) == i[1]:
                 print '   %s' % i[0]
    sys.exit(0)

if sys.argv[1] in [ '-h', '--help' ]:
    print 'Usage:  nfsdebug [flag name] [flag name] ...'
    print '  where flag name is one of: all, none, %s' % \
        ', '.join(NfsDebugFlags.keys())
    sys.exit(1)

for arg in sys.argv:
    if arg == sys.argv[0]:
        continue

    elif arg in [ 'all', 'on', 'true', 'yes' ]:
        SetNfsFlags(AllNfsFlags)
        print 'NFS debugging is now enabled.'

    elif arg in [ 'none', 'off', 'false', 'no', 'clear', 'zero' ]:
        SetNfsFlags(NoNfsFlags)
        print 'NFS debugging is now disabled.'

    else:
        ProcessFlag(arg)

sys.exit(0)

--------------080401060502040901070404
Content-Type: text/plain;
 name="rpcdebug"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rpcdebug"

#!/usr/bin/env python
# -*- python-mode -*-
"""Script to set RPC debug levels symbolically
"""

__copyright__ = """
Copyright (C) 2007, Chuck Lever <chuck.lever@oracle.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License version 2 as
published by the Free Software Foundation.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
"""

""" History:
Thu Jun 21 10:41:40 EDT 2007 cel - created
"""

import sys, os, time, popen2

""" From include/linux/sunrpc/debug.h
"""
RpcDebugFlags = {
    'xprt'    : 0x0001,
    'call'    : 0x0002,
    'debug'   : 0x0004,
    'nfs'     : 0x0008,
    'auth'    : 0x0010,
    'bind'    : 0x0020,
    'sched'   : 0x0040,
    'trans'   : 0x0080,
    'svcsock' : 0x0100,
    'svcdsp'  : 0x0200,
    'misc'    : 0x0400,
    'cache'   : 0x0800,
}

NoRpcFlags = 0
AllRpcFlags = 0x0fff

def DoCmd(cmd):
    p = popen2.Popen3(cmd, True)
    output = p.fromchild.read()
    if p.wait():
        print '%s failed (%s)' % (str(cmd), p.childerr.read().strip())
    return output

def CurrentSetting():
    string = DoCmd("/sbin/sysctl sunrpc.rpc_debug")
    words = string.split()
    return int(words[2])

def SetRpcFlags(flags):
    cmd = '/usr/bin/sudo /sbin/sysctl -w sunrpc.rpc_debug=%d' % flags
    DoCmd(cmd)
    return

def ProcessFlag(flag):
    if flag not in RpcDebugFlags:
        print 'Unrecognized RPC debugging flag.'
        return

    current = CurrentSetting()
    SetRpcFlags(current | RpcDebugFlags[flag])

    return


#
# Main
#

if len(sys.argv) == 1:
    current = CurrentSetting()
    if current == NoRpcFlags:
        print 'RPC debugging is currently disabled.'
    elif current == AllRpcFlags:
        print 'RPC debugging is currently fully enabled.'
    else:
        print 'Current RPC debugging flags:'
        for i in RpcDebugFlags.items():
            if (current & i[1]) == i[1]:
                 print '   %s' % i[0]
    sys.exit(0)

if sys.argv[1] in [ '-h', '--help' ]:
    print 'Usage:  rpcdebug [flag name] [flag name] ...'
    print '  where flag name is one of: all, none, %s' % \
        ', '.join(RpcDebugFlags.keys())
    sys.exit(1)

for arg in sys.argv:
    if arg == sys.argv[0]:
        continue

    elif arg in [ 'all', 'on', 'true', 'yes' ]:
        SetRpcFlags(AllRpcFlags)
        print 'RPC debugging is now enabled.'

    elif arg in [ 'none', 'off', 'false', 'no', 'clear', 'zero' ]:
        SetRpcFlags(NoRpcFlags)
        print 'RPC debugging is now disabled.'

    else:
        ProcessFlag(arg)

sys.exit(0)

--------------080401060502040901070404
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
url:http://oss.oracle.com/~cel/
version:2.1
end:vcard


--------------080401060502040901070404
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--------------080401060502040901070404
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------080401060502040901070404--
