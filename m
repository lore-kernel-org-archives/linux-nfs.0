Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.46]:45034 "EHLO minas.ics.muni.cz"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753294AbcLHMgU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Dec 2016 07:36:20 -0500
Date: Thu, 8 Dec 2016 13:36:17 +0100
From: Lukas Hejtmanek <xhejtman@gmail.com>
To: Andy Adamson <androsadamson@gmail.com>
Cc: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: RFC rpc.gssd enhancement
Message-ID: <20161208123616.nndod3snzoeyr565@ics.muni.cz>
References: <20161128183757.d5pz64tsigmaxdc7@ics.muni.cz>
 <645d0f56-f357-6c58-5e2f-e85bbae93db1@RedHat.com>
 <20161129184843.jrwbnytggrz6kdir@ics.muni.cz>
 <2ff5b760-a3ca-9ab8-d1a8-efe5f36aaaf3@RedHat.com>
 <20161202114134.rvzqptnsqo3odxay@ics.muni.cz>
 <CAHVgHyU6LQak3O4ybR0H3whWCKUdfz2bxLvEGi9uFM1EX+e=Eg@mail.gmail.com>
 <20161202134638.4ghyb5wnnwata4ec@ics.muni.cz>
 <CAHVgHyVWqNZv55dH3hhZ-0XDsd4c79OW_R6Ze02uhv-nqePpPQ@mail.gmail.com>
 <20161202142847.vyhp6ogtu6gvuabf@ics.muni.cz>
 <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <CAHVgHyW6fo1b2LSjxq73n7wQkR9r0JEvwzxHdb3X9p+gSpLQ1Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This discussion seems to be a bit fubar. So I start over again.

I see three problems if $HOME is Kerberized NFS volume, I will call this NFS
client machine.

1) user logs via SSH to the NFS client machine using GSS API, i.e., the user
   has a Kerberos ticket. SSHD on the NFS client machine has to access
   ~/.k5login under root identity (usually host identity). User has to grant
   access to such identity to his/her $HOME and .k5login in there.
   Older version of Kerberos denied access if ~/.k5login had different
   permision than 0600.

2) user logs via SSH to the NFS client machine using password. He/she stays
   logged in, Kerberos ticket expires. Issuing kinit returns an error I've
   already sent, because kinit wants to read ~/.krb5/config file and gets
   EKEYEXPIRED. Kinit does not deal with such an error, it understand olny
   EPERM error. New ticket cannot be created until user deletes ticket from
   TMPDIR (rm, not kdestroy as it does not work either).

3) user wants to log via SSH to the NFS client machine using ssh public key.
   This cannot be done as ~/.ssh/authorized_keys is accessed by SSHD under
   user context (not root context), so EPERM is returned even if user grants
   access to read ~/.ssh/authorized_keys to anyone.

While nothing can be done ad 1). My proposed extension of rpc.gssd would solve
ad 2) and ad 3). As this should be purely rpc.gssd patch, possible attacker
with escalated root access is out of question because the attacker can replace
rpc.gssd on his own. And also in this case, decision whether user gets
EKEYEXPIRED/EPERM or granted access as some particular identity is desicion of
the administator of the NFS client machine.

-- 
Luká¹ Hejtmánek
