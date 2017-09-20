Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51422 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751697AbdITMNP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Sep 2017 08:13:15 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Michael Sterrett" <michael@sterretts.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: f30cb757f680f965ba8a2e53cb3588052a01aeb5 regression
Date: Wed, 20 Sep 2017 08:13:13 -0400
Message-ID: <B4CA251B-5BE1-4D57-B4EC-990AAE7F4AAE@redhat.com>
In-Reply-To: <CA+rTEUMDy-Okdpo1EuWHS5n_6HAm5RKa4OVHPQPddRLP4hdtxw@mail.gmail.com>
References: <CA+rTEUMDy-Okdpo1EuWHS5n_6HAm5RKa4OVHPQPddRLP4hdtxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Michael, can you clarify what you mean by "client machine locks up"?  
Are you receiving reports of a hung task in the kernel logs?

Ben

On 19 Sep 2017, at 1:32, Michael Sterrett wrote:

> Commit f30cb757f680f965ba8a2e53cb3588052a01aeb5 introduced a
> regression.  When starting firefox the nfs client machine locks up.
> Issue remains up to 4.13.2 and latest Linus git repo.
>
> http://wiki.linux-nfs.org/wiki/index.php/Reporting_bugs says:
> The command(s) you were trying to run: firefox
> The exact error message(s) you saw, and/or symptoms encountered:
> machine lockup - no error messages seen
> Which kernel versions are you using on the client and server? server
> is vanilla 4.10.8; client is at mentioned commit
> Are you using any of the security options?  Not as far as I know.
> Results of `exportfs -v` on the server:
>
>  exportfs -v
> /mnt/storage/music
>         192.168.1.0/29(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/pictures
>         192.168.1.0/29(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/home
>         192.168.1.0/29(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/backup
>         192.168.1.0/29(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/downloads
>         192.168.1.0/24(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/gentoo-x86
>         192.168.1.0/29(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/distfiles
>         192.168.1.0/29(rw,wdelay,no_root_squash,no_subtree_check,sec=sys,rw,secure,no_root_squash,no_all_squash)
> /mnt/storage/music
>         <world>(ro,wdelay,no_root_squash,no_subtree_check,sec=sys,ro,secure,no_root_squash,no_all_squash)
> /mnt/storage/pictures
>         <world>(ro,wdelay,no_root_squash,no_subtree_check,sec=sys,ro,secure,no_root_squash,no_all_squash)
> /mnt/storage/downloads
>         <world>(ro,wdelay,no_root_squash,no_subtree_check,sec=sys,ro,secure,no_root_squash,no_all_squash)
>
> client:
> echo acl libgssapi libevent librpcsecgss nfs-utils util-linux | xargs
> -n1 eix '-I' --format '<installedversions:NAMEVERSION>'
> No matches found
> No matches found
> dev-libs/libevent-2.1.8
> No matches found
> net-fs/nfs-utils-1.3.4-r1
> sys-apps/util-linux-2.28.2
>
> server:
> echo acl libgssapi libevent librpcsecgss nfs-utils util-linux | xargs
> -n1 eix '-I' --format '<installedversions:NAMEVERSION>'
> No matches found
> No matches found
> dev-libs/libevent-2.1.8
> No matches found
> net-fs/nfs-utils-1.3.4-r1
> sys-apps/util-linux-2.28.2
>
>
> Here's my git bisect log:
>  git bisect log
> git bisect start
> # bad: [cb6621858813522e62fcba835541e4fcf57b3cb3] Linux 4.12.1
> git bisect bad cb6621858813522e62fcba835541e4fcf57b3cb3
> # good: [bd1a9eb6a755e1cb342725a11242251d2bfad567] Linux 4.11.12
> git bisect good bd1a9eb6a755e1cb342725a11242251d2bfad567
> # good: [a351e9b9fc24e982ec2f0e76379a49826036da12] Linux 4.11
> git bisect good a351e9b9fc24e982ec2f0e76379a49826036da12
> # good: [2bd80401743568ced7d303b008ae5298ce77e695] Merge tag
> 'gpio-v4.12-1' of
> git://git.kernel.org/pub/scm/linux/kernel/git/linusw/linux-gpio
> git bisect good 2bd80401743568ced7d303b008ae5298ce77e695
> # good: [85d604902eb28eaea4f9e0f3a655ae986fa4bd2e] Merge tag
> 'armsoc-dt' of 
> git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc
> git bisect good 85d604902eb28eaea4f9e0f3a655ae986fa4bd2e
> # bad: [af5d28565f5822fb6a280d2de07315dad487f1f1] Merge tag
> 'hwmon-for-linus-v4.12-rc2' of
> git://git.kernel.org/pub/scm/linux/kernel/git/groeck/linux-staging
> git bisect bad af5d28565f5822fb6a280d2de07315dad487f1f1
> # bad: [c70422f760c120480fee4de6c38804c72aa26bc1] Merge tag
> 'nfsd-4.12' of git://linux-nfs.org/~bfields/linux
> git bisect bad c70422f760c120480fee4de6c38804c72aa26bc1
> # good: [4879b7ae05431ebcd228a4ff25a81120b3d85891] Merge tag
> 'dmaengine-4.12-rc1' of git://git.infradead.org/users/vkoul/slave-dma
> git bisect good 4879b7ae05431ebcd228a4ff25a81120b3d85891
> # good: [dc9edaab90de9441cc28ac570b23b0d2bdba7879] Merge tag
> 'acpi-extra-4.12-rc1' of
> git://git.kernel.org/pub/scm/linux/kernel/git/rafael/linux-pm
> git bisect good dc9edaab90de9441cc28ac570b23b0d2bdba7879
> # good: [5ccd414080822d5257c3569f4aeca74f63f4a257] Merge tag
> 'for-linus' of git://git.kernel.org/pub/scm/virt/kvm/kvm
> git bisect good 5ccd414080822d5257c3569f4aeca74f63f4a257
> # bad: [209aa2308365387bc03905b7b4bb36c52ea1e696] nfs/filelayout: fix
> NULL pointer dereference in fl_pnfs_update_layout()
> git bisect bad 209aa2308365387bc03905b7b4bb36c52ea1e696
> # good: [1f84ccdf37d0db3a70714d02d51b0b6d45887fb8] NFS: Fix use after
> free in write error path
> git bisect good 1f84ccdf37d0db3a70714d02d51b0b6d45887fb8
> # bad: [a6598813a4c5bad76322bee2323dc549e7d7180d] NFS: Don't write
> back further requests if there is a pending write error
> git bisect bad a6598813a4c5bad76322bee2323dc549e7d7180d
> # good: [675e508f53e2cc0b1ab750a0ff2b477ccbab4cfb] pNFS: unexport
> nfs4_pnfs_v3_ds_connect_unload
> git bisect good 675e508f53e2cc0b1ab750a0ff2b477ccbab4cfb
> # good: [7d6ddf88c4db372689c8aa65ea652d0514d66c06] NFS: Add an
> iocounter wait function for async RPC tasks
> git bisect good 7d6ddf88c4db372689c8aa65ea652d0514d66c06
> # bad: [f30cb757f680f965ba8a2e53cb3588052a01aeb5] NFS: Always wait for
> I/O completion before unlock
> git bisect bad f30cb757f680f965ba8a2e53cb3588052a01aeb5
> # good: [b1ece737f44f91dca8f4829cf0b442e752e406db] lockd: Introduce
> nlmclnt_operations
> git bisect good b1ece737f44f91dca8f4829cf0b442e752e406db
> # first bad commit: [f30cb757f680f965ba8a2e53cb3588052a01aeb5] NFS:
> Always wait for I/O completion before unlock
>
> Happy to supply any additional information as needed.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
