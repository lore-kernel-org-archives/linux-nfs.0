Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:41837 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758630Ab2BIXDb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Feb 2012 18:03:31 -0500
From: "Bhamare, Sachin" <sbhamare@panasas.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: Jim Rees <rees@umich.edu>, Steve Dickson <SteveD@redhat.com>,
        "Harrosh, Boaz" <bharrosh@panasas.com>,
        Benny Halevy <bhalevy@tonian.com>,
        "osd-dev@open-osd.org" <osd-dev@open-osd.org>
Subject: nfs-utils: userspace support for autologin feature in object layout
 driver
Date: Thu, 9 Feb 2012 23:02:51 +0000
Message-ID: <CB5990C9.679A%sbhamare@panasas.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi, 
   I have been working on implementing autologin support for objectlayout
driver in pNFS client. This feature would allow pNFS object clients to
receive an URI (e.g. iscsi://<IP>:<PORT>) of a target OSD via
GETDEVICEINFO rpc from the server. Object layout driver would then pass
this information to an user space daemon which would perform the login
task 
depending on the protocol involved (e.g. Iscsi login using iscsiadm).

For userspace daemon, we have 2 implementation choices.

1. Add new daemon (say, osdlogind) to nfs-utils which would process the
upcalls from object layout driver via rpc_pipefs (very similar to the way
blkmapd works)
2. Modify blkmapd in nfs-utils package to be able to process upcalls from
the object layout driver and add new functionality to process these
messages.

I think, (1) above is the simplest and cleanest way to go about
implementing this. (2) adds an indirect dependency between block layout
driver and object layout driver if they were to share the same rpc pipe to
communicate with user space.

Currently I have a simple implementation of 'osdlogind' coded up which
borrows its design heavily from 'blkmapd' code. Please let me know what
would be the preferred way to go about this. Thanks in advance for your
inputs. 

Sachin Bhamare 
Panasas Inc.


