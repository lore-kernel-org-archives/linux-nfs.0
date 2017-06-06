Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54538 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751691AbdFFJoH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Jun 2017 05:44:07 -0400
Date: Tue, 6 Jun 2017 11:43:58 +0200
From: Karel Zak <kzak@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: util-linux@vger.kernel.org,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Franck Bui <fbui@suse.com>
Subject: Re: [util-linux PATCH] umount: never 'stat' the path when "-c" is
 given.
Message-ID: <20170606094358.it2vnzppmabsrone@ws.net.home>
References: <8760gbduzp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8760gbduzp.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 05, 2017 at 12:32:58PM +1000, NeilBrown wrote:
> So, this patch treats "-c" much like "-l" and "-f" when
> deciding whether it is safe to 'stat' the path.

Ah, definitely good idea. Applied, thanks.

    Karel

-- 
 Karel Zak  <kzak@redhat.com>
 http://karelzak.blogspot.com
