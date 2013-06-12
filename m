Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:26011 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752985Ab3FLQBg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Jun 2013 12:01:36 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: [PATCH 0/3] Various gssd fixes including machine-credential issue.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130612161240.59b219b7@notabene.brown>
Date: Wed, 12 Jun 2013 12:01:28 -0400
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org
Message-Id: <617282A2-6881-47B7-BE8F-752728195AF1@oracle.com>
References: <20130603005219.20080.1927.stgit@notabene.brown> <A2E2CEA9-4F2B-4A3F-8661-36D1E6288B0F@oracle.com> <20130603122319.47f4e0dd@notabene.brown> <0016A272-E433-4020-91FE-45A5EE494296@oracle.com> <20130603130101.4acfe706@notabene.brown> <C4A2C0D1-8900-45AC-90F6-9629E3F71730@oracle.com> <20130604093025.5e467eeb@notabene.brown> <9F47F7D4-9D96-424E-BAD9-21AE1C06A877@oracle.com> <2195C785-9764-48CC-A994-A80B7A8EDC62@oracle.com> <20130605112635.188f628e@notabene.brown> <1ECE6C65-EE15-46C1-97D1-636B15A775F7@oracle.com> <20130606094336.4faf099d@notabene.brown> <20130612161240.59b219b7@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 12, 2013, at 2:12 AM, NeilBrown <neilb@suse.de> wrote:

> On Thu, 6 Jun 2013 09:43:36 +1000 NeilBrown <neilb@suse.de> wrote:
> 
>> I've provided a patched kernel to customer.  Hopefully will hear back soon.
> 
> Hi Chuck,
> the patch appears to work exactly as advertised and completely resolves the
> issue - thanks.

Thanks to you and your customer for confirming the approach.

Unfortunately Trond NAK'd a for-3.10 patch that uses RPC_TASK_ROOTCREDS.  I posted a patch Friday that takes a different approach to acquiring the root user's credentials that should behave like the old patch in every way, and be easier to back-port.

> Getting back to the idea of making this sort of thing work seamlessly,
> another possibility to consider is to use the *real* uid  of the process
> which performs the mount do authenticate SETCLIENTID - either as the primary
> authentication or as a fall-back.
> Then the a mountpoint with "users" listed as an option in /etc/fstab can be
> mounted by anyone with appropriate credentials and no credential should be
> needed for root, and not machine credential should be needed either.

Perhaps a more common use case with NFSv4 is secure automounter mounts.  In that case, the server can be configured to allow sec=sys access to it's pseudo-fs, then require Kerberos for its real file systems.

In operation, the client mounts the server's pseudo-fs without needing any GSS context.  When it transitions into a protected file system, the server returns NFS4ERR_WRONGSEC and the client should be able to negotiate up to AUTH_GSS using the user's credential.  (Mind you I haven't tried this, I'm simply hand-waving based on reasonable assumptions).

The key feature of this use case is that the client is not configured for anything but /net.  Mount options like "sec=krb5" or "users" are simply not in the picture.

The question is still whether, if the client doesn't have a keytab, lease management should use the user's credential or AUTH_SYS.  I maintain that AUTH_SYS is a better choice.  The kernel cannot possibly know a priori, without configuration, that this is a single-user client and that it is OK to use a user's Kerberos credential for lease management.

I'll stress that the reason we prefer a machine credential (either AUTH_GSS or AUTH_SYS) is because a client must present a consistent principal and flavor to the server for lease management.

A server can refuse to recognize a SETCLIENTID (for example, after a sudden client reboot) if there is already a lease on the server for using the presented nfs_client_id4.id string that was established using a different security flavor or principal.  Otherwise there would be no point in securing lease management.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




