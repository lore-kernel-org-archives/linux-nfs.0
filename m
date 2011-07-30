Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([83.163.148.79]:60571 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751045Ab1G3Jo2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Jul 2011 05:44:28 -0400
Date: Sat, 30 Jul 2011 11:44:26 +0200
From: Frank van Maarseveen <frankvm@frankvm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>,
        jlayton@redhat.com
Subject: Re: [NLM] support for a per-mount grace period.
Message-ID: <20110730094426.GA17614@janus>
References: <1311878660-24482-1-git-send-email-frankvm@frankvm.com>
 <20110729171126.GN23194@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110729171126.GN23194@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jul 29, 2011 at 01:11:27PM -0400, J. Bruce Fields wrote:
> On Thu, Jul 28, 2011 at 08:44:18PM +0200, Frank van Maarseveen wrote:
> > The following two patches implement support for a per-mount NLM
> > grace period. The first patch is a minor cleanup which pushes
> > down locks_in_grace() calls into functions shared by NFS[234]. Two
> > locks_in_grace() tests have been reordered to avoid duplicate calls at
> > run-time (assuming gcc is smart enough). nlmsvc_grace_period is now a
> > function instead of an unused variable.
> > 
> > The second patch is the actual implementation. It is currently in use for
> > a number of NFSv3 virtual servers on one physical machine running 2.6.39.3
> > where the virtualization is based on using different IPv4 addresses.
> 
> Thanks, that is something we'd like to have working well.
> 
> Off the top of my head:
> 	- Do you have a plan for dealing with NFSv4?

Not yet but I'm not aware of any additional issue there (I haven't used v4 yet).

> 	- Do you need any more kernel changes to get this working?

No.

> 	- What about userspace changes?

None except for scripting. Years ago I had to grab a random sm-notify
to make it work. At that time (2.6.27) there was a different patch
for fsid based grace times from Wendy Cheng.

> 	- Do you support migrating/failing over virtual nfs service
> 	  between machines, and if so, how are you doing it?

Migration basically works as follows:

-	Create a network block device on the source machine to access a
	new physical block device on the destination.

-	Shutdown the virtual server, create a RAID-1 device on top of
	the original block device and start the server for the resulting
	device. The mdadm command (v2.5.6, 2006) is something like:

	mdadm -B -ayes -n2 -l1 $md $localdev -b $bitmap --write-behind missing

-	Add the network block device to synchronize the destination:

	mdadm $md --add --write-mostly $nbd

-	When RAID-1 has synchronized then shutdown the virtual server
	on the source machine and start it on the destination, i.e. migrate
	its IP address.

A virtual server IP address removal is always accompanied by a

	iptables -I OUTPUT -s $ADDR -j DROP

because traffic can still be in-flight causing troubles (have seen
ESTALE). Every virtual server has its own statd directory (and a
private "state" file), basically maintained from /var/lib/nfs/*. Upon
startup after a crash the latter must be saved before the standard
rpc.statd/sm-notify get a chance to empty it.

-- 
Frank
