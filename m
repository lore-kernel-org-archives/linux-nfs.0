From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 16:23:32 +0200
Message-ID: <20100614142332.GB17703@ics.muni.cz>
References: <20100614085157.GS17703@ics.muni.cz>
 <4C163892.20201@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:48126 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754533Ab0FNOXc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 10:23:32 -0400
In-Reply-To: <4C163892.20201@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Mon, Jun 14, 2010 at 10:11:30AM -0400, Benny Halevy wrote:
> I'm not sure if that explains the 15 seconds delay.
> I wonder if it could be related to the nfsv4 grace period.
> Does this happen if you wait for a couple minutes after
> the server restarts before starting the test?

I repeated the test after approx. 6 hours the server was restarted and =
it is
the same, the delay still happens.=20

But it could be something related, it complains about lease renewal:

Jun 14 16:17:00 undomiel1 kernel: [187434.936220] nfs4_renew_state: don=
e
Jun 14 16:17:00 undomiel1 kernel: [187434.936492] nfs41_sequence_done: =
Error 0 free the slot
Jun 14 16:17:00 undomiel1 kernel: [187434.936500] nfs4_free_slot: free_=
slotid 0 highest_used_slotid -1
Jun 14 16:17:00 undomiel1 kernel: [187434.936507] nfs41_sequence_call_d=
one rpc_cred ffff88003d7a0300
Jun 14 16:17:00 undomiel1 kernel: [187434.936514] <-- nfs41_sequence_ca=
ll_done
Jun 14 16:17:00 undomiel1 kernel: [187434.936522] nfs4_schedule_state_r=
enewal: requeueing work. Lease period =3D 60
Jun 14 16:17:00 undomiel1 kernel: [187434.936530] --> nfs_put_client({2=
})
Jun 14 16:17:16 undomiel1 kernel: [187450.536014] nfs4_renew_state: sta=
rt
Jun 14 16:17:16 undomiel1 kernel: [187450.536045] nfs4_renew_state: fai=
led to call renewd. Reason: lease not expired
Jun 14 16:17:16 undomiel1 kernel: [187450.536056] nfs4_schedule_state_r=
enewal: requeueing work. Lease period =3D 38

The full log can be found at:
http://undomiel.ics.muni.cz/tmp/nfs-log.txt

--=20
Luk=E1=B9 Hejtm=E1nek
