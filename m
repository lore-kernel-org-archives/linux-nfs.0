Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:55368 "EHLO minas.ics.muni.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758922AbcLBOhg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 2 Dec 2016 09:37:36 -0500
Date: Fri, 2 Dec 2016 15:28:47 +0100
From: Lukas Hejtmanek <xhejtman@gmail.com>
To: Andy Adamson <androsadamson@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: RFC rpc.gssd enhancement
Message-ID: <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
 <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
 <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz>
 <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz>
 <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 02, 2016 at 09:23:30AM -0500, Andy Adamson wrote:
> In your environment, UID 0 on the client machine (the machine
> credential in the host keytab) is mapped to nobody/nobody when
> accessing the NFS server.

well, ok, and this is what I want for users without kerberos tickets. Map them
to nobody/nogroup instead of error EPERM or EKEYEXPIRED. And I want this as an
option for administator of NFS client machine.

-- 
Luká¹ Hejtmánek
