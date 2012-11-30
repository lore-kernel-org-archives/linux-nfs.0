Return-Path: linux-nfs-owner@vger.kernel.org
Received: from esgaroth.petrovitsch.at ([78.47.184.11]:4344 "EHLO
	esgaroth.petrovitsch.priv.at" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758399Ab2K3OUK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 Nov 2012 09:20:10 -0500
Subject: Re: Possible to make nfs aware of a inotify watch has been set.
From: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
To: Stef Bon <stefbon@gmail.com>
Cc: Steve French <smfrench@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-cifs <linux-cifs@vger.kernel.org>
Date: Fri, 30 Nov 2012 14:37:20 +0100
In-Reply-To: <CANXojcwRy5cBz=E1S567J-1BFC4AiamLr=35bKrX0Zq-Me2b3w@mail.gmail.com>
References: <CANXojcy9thLBwrENTkOTSSE17L3N17A8XsTmyNqq3oNdhW_Q_w@mail.gmail.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B329CFD@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcxR9673fRObMLPSScogAN05RSVhPFoni=ENc6YDWq9T7w@mail.gmail.com>
	 <1354202525.4064.1.camel@pico.ipa.ssimo.org>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA90B32AEB7@SACEXCMBX04-PRD.hq.netapp.com>
	 <CANXojcys4wR8N-R3oSjWRWJLsObn0Qf+i41vBUaNnJctdcrKVw@mail.gmail.com>
	 <20121129202037.GQ4939@ZenIV.linux.org.uk>
	 <CANXojcw15RdJdRoZxB3Z59YbOda7vG7RDRegfpoCjG4Bv4AvsQ@mail.gmail.com>
	 <20121129211624.GS4939@ZenIV.linux.org.uk>
	 <CANXojcxfrO+Ar4JSd0NiDJh7+_gg6s6cq5=UA7Pu1h4DRZ8Vkg@mail.gmail.com>
	 <CAH2r5muw1U2XNMZsCq0gApuTMyj+6SN6S9KsUq52YM8CyZEG4A@mail.gmail.com>
	 <CANXojcwRy5cBz=E1S567J-1BFC4AiamLr=35bKrX0Zq-Me2b3w@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1354282642.22426.7.camel@thorin>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

Since you introduced the "user experience" ignoring the fact that each
user is quite different - especially if it comes to the "Average Joes
using Ubuntu vs techies" department -, you should be prepared to eat
your own dog food:

On Fre, 2012-11-30 at 08:10 +0100, Stef Bon wrote:
[...]
> At this moment the different events look like:

Perhaps you should have used hexadecimal notation so that it is easier
for the usual/average users of source code to see the bits more easily.
In short: Please improve the user experience. Thank you.

> #define NOTIFYFS_FSEVENT_META_ATTRIB_NOTSET                     2
> #define NOTIFYFS_FSEVENT_META_ATTRIB_MODE                       4
> #define NOTIFYFS_FSEVENT_META_ATTRIB_OWNER                      8
> #define NOTIFYFS_FSEVENT_META_ATTRIB_GROUP                      16
> #define NOTIFYFS_FSEVENT_META_ATTRIB                            28
And that number seems pretty random - not a power of 2 or a bit mask or
the sum of the above.

> #define NOTIFYFS_FSEVENT_META_XATTR_NOTSET                      32
> #define NOTIFYFS_FSEVENT_META_XATTR_CREATE                      64
> #define NOTIFYFS_FSEVENT_META_XATTR_MODIFY                      128
> #define NOTIFYFS_FSEVENT_META_XATTR_DELETE                      256
> #define NOTIFYFS_FSEVENT_META_XATTR                             448
And that number seems pretty random too - not a power of 2 or a bit mask
or the sum of the above.

> #define NOTIFYFS_FSEVENT_FILE_NOTSET                            512
> #define NOTIFYFS_FSEVENT_FILE_MODIFIED                          1024
> #define NOTIFYFS_FSEVENT_FILE_SIZE                              2048
> #define NOTIFYFS_FSEVENT_FILE_OPEN                              4096
> #define NOTIFYFS_FSEVENT_FILE_READ                              8192
> #define NOTIFYFS_FSEVENT_FILE_CLOSE_WRITE                       16384
> #define NOTIFYFS_FSEVENT_FILE_CLOSE_NOWRITE                     32768

> #define NOTIFYFS_FSEVENT_MOVE_NOTSET                            65536

And from here own I'm too lazy to calculate (or even guess) if these are
actually powers of 2 or not.
> #define NOTIFYFS_FSEVENT_MOVE_CREATED                           131072
> #define NOTIFYFS_FSEVENT_MOVE_MOVED                             262144
> #define NOTIFYFS_FSEVENT_MOVE_MOVED_FROM                        524288
> #define NOTIFYFS_FSEVENT_MOVE_MOVED_TO                          1048576
> #define NOTIFYFS_FSEVENT_MOVE_DELETED                           2097152
> 
> #define NOTIFYFS_FSEVENT_FS_NOTSET                              4194304
> #define NOTIFYFS_FSEVENT_FS_MOUNT                               8388608
> #define NOTIFYFS_FSEVENT_FS_UNMOUNT                             16777216
> #define NOTIFYFS_FSEVENT_FS_NLINKS                              33554432

MfG,
	Bernd
-- 
Bernd Petrovitsch                  Email : bernd@petrovitsch.priv.at
                     LUGA : http://www.luga.at

