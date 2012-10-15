Return-Path: linux-nfs-owner@vger.kernel.org
Received: from intranet.asianux.com ([58.214.24.6]:62063 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751870Ab2JOFiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Oct 2012 01:38:00 -0400
Message-ID: <507BA178.7030002@asianux.com>
Date: Mon, 15 Oct 2012 13:39:04 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [Bug fix] nfs-client: fix nfs_inode_attrs_need_update for async
 read_done comes during truncating to smaller size
References: <507B70F1.7040903@asianux.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909236BB5@SACEXCMBX04-PRD.hq.netapp.com> <507B968A.9090104@asianux.com>
In-Reply-To: <507B968A.9090104@asianux.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

于 2012年10月15日 12:52, Chen Gang 写道:
>> Now, what are the conditions of your test setup? The above bug report is
>> > meaningless unless it includes a description of what is being exported
>> > by the server (including a proper listing of the contents
>> > of /etc/exports and /proc/mounts). It should also include a description
>> > of the NFS client mount options (see /proc/mounts on the client).

for exportfs command line is:
  rsh -n $RHOST "/usr/sbin/exportfs -i -o no_root_squash,rw *:$TESTDIR"

  $RHOST is dhcp122.asianux.net (10.1.0.122, not need input password)
  $TESTDIR just the mount dir.


> they are below, if you need additional information, please tell me again.
> 


-- 
Chen Gang

Asianux Corporation
