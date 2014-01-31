Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34199 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753976AbaAaQPh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 31 Jan 2014 11:15:37 -0500
Message-ID: <52EBCC23.3050406@RedHat.com>
Date: Fri, 31 Jan 2014 11:15:31 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: NeilBrown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH/RFC: nfs-utils] Common systemd unit files for nfs-utils.
References: <20140130172451.7a354ce4@notabene.brown>	<52EAB0CA.2090204@RedHat.com> <20140131091455.550e59a8@notabene.brown>
In-Reply-To: <20140131091455.550e59a8@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/30/2014 05:14 PM, NeilBrown wrote:
> On Thu, 30 Jan 2014 15:06:34 -0500 Steve Dickson <SteveD@redhat.com> wrote:
>>> diff --git a/systemd/README b/systemd/README
>>> new file mode 100644
>>> index 000000000000..f0fb68825499
>>> --- /dev/null
>>> +++ b/systemd/README
>>> @@ -0,0 +1,50 @@
>>> +
>>> +Notes about systemd unit files for nfs-utils.
>>> +
>>> +The unit files provided here should be sufficient for systemd
>>> +to manage all daemons and related services provides by nfs-utils.
>>> +
>>> +They do *not* include any unit files for separate services such as
>>> +rpc.rquotad (in the 'quota' package) or rpcbind.
>>> +
>>> +There are 4 units that can be 'enabled' or 'disabled' by systemctl, or
>>> +by a suitable 'preset' setting:
>>> +
>>> + nfs-server.target
>>> +    If enabled, nfs service is started together with dependencies
>>> +    such as mountd, statd, rpc.idmapd
>>> +
>>> + nfs-client.target
>>> +    If enabled, daemons needs for an nfs client are enabled.
>>> +    This does *not* include rpc.statd.  the rpc-statd.service unit
>>> +    is started by /usr/sbin/start-statd which mount.nfs will run
>>> +    if statd is needed.
>>> +
>>> + nfs-secure.target
>>> +    If enabled, then rpc.gssd will be run when either -client or
>>> +    -server is started, and rpc.svcgssd will be run when -server
>>> +    is started
>>> +
>>> + nfs-blkmap.target
>>> +    If enabled, then blkmapd will be run when nfs-client.target is
>>> +    started.
We should also somehow document the targets we come up with. That
was some of the frustration that was expressed when we move
to systemd... It was not so much the changes it was the fact there
was no documentation describing the changes... 

Also note I've separated out each file into a separate commit. 
I thought it would be easier to review that way... 
Those commits are on the systemd branch in my git tree:

   git://linux-nfs.org/~steved/nfs-utils systemd

Finally... Who well are these tested? :-) 

steved.
