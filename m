Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752677AbcKBN1g (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Nov 2016 09:27:36 -0400
Subject: Re: [PATCH - rpcbind] Provide systemd unit files for rpcbind
To: NeilBrown <neilb@suse.com>
References: <87oa2q14yc.fsf@notabene.neil.brown.name>
 <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
 <87r36vq85k.fsf@notabene.neil.brown.name>
Cc: libtirpc-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com>
Date: Wed, 2 Nov 2016 09:27:34 -0400
MIME-Version: 1.0
In-Reply-To: <87r36vq85k.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/01/2016 04:04 PM, NeilBrown wrote:
> On Wed, Nov 02 2016, Steve Dickson wrote:
> 
>>> diff --git a/systemd/rpcbind.service.in b/systemd/rpcbind.service.in
>>> new file mode 100644
>>> index 000000000000..4706b5a77abf
>>> --- /dev/null
>>> +++ b/systemd/rpcbind.service.in
>>> @@ -0,0 +1,17 @@
>>> +[Unit]
>>> +Description=RPC Bind
>>> +Documentation=man:rpcbind(8)
>>> +DefaultDependencies=no
>>> +RequiresMountsFor=/var/run /run
>>> +# Make sure we use the IP addresses listed for
>>> +# rpcbind.socket, no matter how this unit is started.
>>> +Wants=rpcbind.socket
>>> +After=rpcbind.socket
>>> +
>>> +[Service]
>>> +Type=notify
>>> +# distro can provide a drop-in adding EnvironmentFile=-/??? if needed.
>>> +ExecStart=@_bindir@/rpcbind $RPCBIND_OPTIONS -w -f
>> This macro puts rpcbind in /usr/bin, but in the Red Hat
>> distros rpcbind lives /usr/sbin. I could easily patch
>> it to do the right thing... but is this a typo or does 
>> rpcbind live in /usr/bin in other distros? 
> 
> oops, posted previous reply too quickly.
> 
> Hmm.. I have rpcbind in /sbin, but my rpm spec file
> runs configure with "--bindir=/sbin"
> The rpcbind makefile just installs rpcbind (and rpcbind) in bindir.
> So presumably you run configure with --bindir=/usr/sbin ??
I just took a look and we don't set that... Here is what we
set in Fedora

RPCBDIR=/tmp
%configure CFLAGS="$CFLAGS" LDFLAGS="-pie" \
    --enable-warmstarts \
    --with-statedir="$RPCBDIR" \
    --with-rpcuser="$RPCBUSR" \
    --with-nss-modules="files altfiles" \
    --enable-libwrap \
    --enable-debug

but in RHEL we set RPCBDIR to /run... 

steved.
