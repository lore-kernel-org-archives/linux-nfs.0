From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: rpc.statd is not running but is required
Date: Mon, 2 May 2011 03:03:28 -0700 (PDT)
Message-ID: <830501.99174.qm@web111711.mail.gq1.yahoo.com>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com> <20110502183547.7e9f1295@notabene.brown> <4DBE80CE.8070406@conversis.de>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs <linux-nfs@vger.kernel.org>
To: Dennis Jacobfeuerborn <dennisml@conversis.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm21.bullet.mail.sp2.yahoo.com ([98.139.91.91]:31538 "HELO
	nm21.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754122Ab1EBKD3 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 06:03:29 -0400
In-Reply-To: <4DBE80CE.8070406@conversis.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I heve this service
=A0
mahmood@server:~$ sudo=A0 /etc/init.d/nfs-kernel-server restart
=A0* Stopping NFS kernel daemon=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK ]
=A0* Unexporting directories for NFS kernel daemon...=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK ]
=A0* Exporting directories for NFS kernel daemon...=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK=
 ]
=A0* Starting NFS kernel daemon=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK ]

=A0
I use debian based linux. Is that what you meant?

// Naderan *Mahmood;


----- Original Message -----
=46rom: Dennis Jacobfeuerborn <dennisml@conversis.de>
To: NeilBrown <neilb@suse.de>
Cc: Mahmood Naderan <nt_mahmood@yahoo.com>; nfs <linux-nfs-u79uwXL29TasMV2rI37PzA@public.gmane.org=
org>
Sent: Monday, May 2, 2011 2:30 PM
Subject: Re: rpc.statd is not running but is required

On 05/02/2011 10:35 AM, NeilBrown wrote:
> On Mon, 2 May 2011 00:59:01 -0700 (PDT) Mahmood Naderan
> <nt_mahmood@yahoo.com>=A0 wrote:
>
>> Hi,
>> I have setup NFS and I checked every thing with documents and manual=
=2E
>> After the client boots up, it says:
>>
>>
>> mount.nfs: rpc.statd is not running but is required for remote locki=
ng.
>> mount.nfs: Either use '-o nolock' to keep locks local, or start stat=
d.
>> mountall: mount /opt [1000] terminated with status 32
>
> mount tried to run=A0 /usr/sbin/start-statd and it failed for some re=
ason.
> What is in /usr/sbin/start-statd ??
> What happens if you run it directly?
> What happens if you just run=A0 /usr/sbin/rpc.statd??
>

Have you tried checking if the /etc/init.d/nfslock service is enabled a=
nd=20
running?

Regards,
=A0  Dennis

