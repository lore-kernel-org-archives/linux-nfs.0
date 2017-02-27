Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-phx2.redhat.com ([209.132.183.24]:57050 "EHLO
        mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdB1Ca7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Feb 2017 21:30:59 -0500
Date: Mon, 27 Feb 2017 17:47:18 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        bcodding@redhat.com, asavkov@redhat.com
Message-ID: <343033867.485297.1488235638227.JavaMail.zimbra@redhat.com>
In-Reply-To: <9557.1488233061@warthog.procyon.org.uk>
References: <cover.1487802542.git.jstancek@redhat.com> <9557.1488233061@warthog.procyon.org.uk>
Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----
> From: "David Howells" <dhowells@redhat.com>
> To: "Jan Stancek" <jstancek@redhat.com>
> Cc: dhowells@redhat.com, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, bcodding@redhat.com,
> asavkov@redhat.com
> Sent: Monday, 27 February, 2017 11:04:21 PM
> Subject: Re: [PATCH 0/2] key payload access with just rcu_read_lock()
> 
> Jan Stancek <jstancek@redhat.com> wrote:
> 
> > this is a follow-up for "suspicious RCU usage" warning described
> > in these 2 linux-nfs threads:
> >   http://marc.info/?t=147558830300003&r=1&w=2
> >   http://marc.info/?t=148776770500001&r=1&w=2
> > 
> > Did you have something like in mind?
> 
> How about the attached?  It's similar to what you did, but I made the split
> functions different from the original so that all users have to reconsider
> what they actually want.
> 
> David

Looks like there are still couple users that need updating,
I'm hitting following compilation error:

...
  CC [M]  fs/cifs/connect.o
fs/cifs/connect.c: In function ‘cifs_set_cifscreds’:
fs/cifs/connect.c:2442:2: error: implicit declaration of function ‘user_key_payload’ [-Werror=implicit-function-declaration]
  upayload = user_key_payload(key);
  ^
fs/cifs/connect.c:2442:11: error: assignment makes pointer from integer without a cast [-Werror]
  upayload = user_key_payload(key);
           ^

# grep "user_key_payload(" -r . --include=*.c
./drivers/md/dm-crypt.c:        ukp = user_key_payload(key);
./fs/cifs/connect.c:    upayload = user_key_payload(key);
./fs/crypto/keyinfo.c:  ukp = user_key_payload(keyring_key);
./lib/digsig.c: ukp = user_key_payload(key);

# grep "user_key_payload(" -r . --include=*.h
./fs/ecryptfs/ecryptfs_kernel.h:                return (struct ecryptfs_auth_tok *)user_key_payload(key)->data;

Regards,
Jan
