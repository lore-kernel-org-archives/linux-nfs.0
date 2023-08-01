Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7278C00528
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Aug 2023 17:01:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230375AbjHARBX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Aug 2023 13:01:23 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:45474 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232699AbjHARBW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Aug 2023 13:01:22 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5C53A2114;
        Tue,  1 Aug 2023 10:01:21 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
         key-exchange X25519 server-signature RSA-PSS (2048 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id BCF0661467;
        Tue,  1 Aug 2023 17:01:20 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA76AC433C8;
        Tue,  1 Aug 2023 17:01:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1690909280;
        bh=V4wsRi7dF+gdHpYldqmIxmxjUn2UTVH56/cwwCtxOwE=;
        h=Subject:From:To:Date:From;
        b=VhbAGLKWUDY/Eq/kJgVvlUFbwbi/w16OZYtgNfo/liJXFuZn0fMf6a1CSYda25NGK
         p/YKW0NQhIYdYVyZP0a+UHF5zMz9jNJy7s4owTv9PgcitWJ35ARxl01daoweFi7Iiy
         FwtTGyvkD2j/NNVfQnh18EDV6Bv529XN2QoVC6i5yQ7eOFQIdpChoLwO1ETbXdWJ2s
         HrSN7MXCf52uiXmpeQyM2FNv0KS1ZI9NSDFGqSVGeoAK83U1WOHgwkymGknBZMpwbA
         ZlSyVR5Fw5J/Y+A/gIBWc/Ge1jLLX3x9F6vfsYJNSaIGnYTkwM3pki1nL1lyq4DUYH
         WFLCw/OPiDGdw==
Message-ID: <3aba8d909955253a4630f66d0f72ee35f103a948.camel@kernel.org>
Subject: nfs remounting regression in v6.5-rc1
From:   Jeff Layton <jlayton@kernel.org>
To:     linux-nfs <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
Date:   Tue, 01 Aug 2023 13:01:18 -0400
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.48.4 (3.48.4-1.fc38) 
MIME-Version: 1.0
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've hit a regression that crept in sometime after v6.5-rc1. If I have 2
NFS mounts on a client that are mounting 2 directories of the same
export, and then I remount one of them ro, the other will also flip to
being ro as well. For instance:

[vagrant@kdevops-nfs-default ~]$ sudo mount kdevops-nfsd:/export/fstests/kd=
evops-nfs-default/test /media/test
[vagrant@kdevops-nfs-default ~]$ sudo mount kdevops-nfsd:/export/fstests/kd=
evops-nfs-default/scratch /media/scratch
[vagrant@kdevops-nfs-default ~]$ mount -v | grep nfs
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
kdevops-nfsd:/export/fstests/kdevops-nfs-default/test on /media/test type n=
fs4 (rw,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D255,ha=
rd,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D192.168.122.7=
9,local_lock=3Dnone,addr=3D192.168.122.138)
kdevops-nfsd:/export/fstests/kdevops-nfs-default/scratch on /media/scratch =
type nfs4 (rw,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D=
255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D192.168=
.122.79,local_lock=3Dnone,addr=3D192.168.122.138)
[vagrant@kdevops-nfs-default ~]$ sudo mount kdevops-nfsd:/export/fstests/kd=
evops-nfs-default/scratch /media/scratch -o remount,ro
[vagrant@kdevops-nfs-default ~]$ mount -v | grep nfs
sunrpc on /var/lib/nfs/rpc_pipefs type rpc_pipefs (rw,relatime)
kdevops-nfsd:/export/fstests/kdevops-nfs-default/test on /media/test type n=
fs4 (ro,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D255,ha=
rd,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D192.168.122.7=
9,local_lock=3Dnone,addr=3D192.168.122.138)
kdevops-nfsd:/export/fstests/kdevops-nfs-default/scratch on /media/scratch =
type nfs4 (ro,relatime,vers=3D4.2,rsize=3D1048576,wsize=3D1048576,namlen=3D=
255,hard,proto=3Dtcp,timeo=3D600,retrans=3D2,sec=3Dsys,clientaddr=3D192.168=
.122.79,local_lock=3Dnone,addr=3D192.168.122.138)

=20
In v6.4, /media/test stays rw. Mounting with -o nosharecache works
around the problem (since that disables superblock sharing). This also
manifests as a failure in fstest generic/306.

I'm running a bisect now to try and track down the problem, but if
anyone has thoughts on the cause, let me know.

Cheers,
--=20
Jeff Layton <jlayton@kernel.org>
