Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:45906 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752852AbdKJNxL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 08:53:11 -0500
MIME-Version: 1.0
In-Reply-To: <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk> <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com> <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 10 Nov 2017 14:53:09 +0100
Message-ID: <CAK8P3a0GabFsSw5Kq4HKOFPjCuziokkh4mTv-FYS-oZ-Zq7tQQ@mail.gmail.com>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and 4.13.11
To: Patrick McLean <chutzpah@gentoo.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Nov 10, 2017 at 2:58 AM, Patrick McLean <chutzpah@gentoo.org> wrote:
> On 2017-11-09 12:04 PM, Linus Torvalds wrote:
>> On Thu, Nov 9, 2017 at 11:51 AM, Patrick McLean <chutzpah@gentoo.org> wrote:

>
> We will check our fork against the in-kernel cp201x driver to make sure
> we didn't miss anything, but it seems odd we would be hitting the issue
> so consistently in the NFS code path, rather than somewhere in USB,
> serial, or GPIO paths.
>
>> So since you seem to be able to reproduce this _reasonably_ easily,
>> it's definitely worth checking that it still reproduces even without
>> the gcc plugins.
>
> I haven't been able to reproduce it with RANDSTRUCT disabled (and
> structleak enabled). I will keep trying for a little while more, but
> evidence seems to be pointing to that.
>
> Something must have changed since 4.13.8 to trigger this though. This
> did not crop up at all until we tried 4.13.11, where it we saw it pretty
> quickly. We have a pretty large number of machines running 4.13.6 with
> RANDSTRUCT enabled and running a the same workload with many more
> clients, and have not seen this bug at all.

I couldn't find anything overly suspicious between 4.13.8 and 4.13.11,
see the full list of commits since 3.14.6 at https://pastebin.com/AcxBZR7H

The ones I couldn't immediately rule out (but no smoking gun either) would be:

9970679f497a x86/cpu/AMD: Apply the Erratum 688 fix when the BIOS doesn't
ca6711747c5a assoc_array: Fix a buggy node-splitting case
2fbb8bf749b5 xfs: move two more RT specific functions into CONFIG_XFS_RT
1e1427356d8d xfs: trim writepage mapping to within eof
9df9b634f637 xfs: cancel dirty pages on invalidation
cd3f0bee1b94 xfs: handle error if xfs_btree_get_bufs fails
58cfca25f540 xfs: reinit btree pointer on attr tree inactivation walk
659a9989b68b xfs: don't change inode mode if ACL update fails
88ccd3b6884a xfs: move more RT specific code under CONFIG_XFS_RT
5733ebee586c xfs: Don't log uninitialised fields in inode structures
199a7448c097 xfs: handle racy AIO in xfs_reflink_end_cow
ee5d69c908a1 xfs: always swap the cow forks when swapping extents
2888145444f1 xfs: Capture state of the right inode in xfs_iflush_done
d0fa252b207f xfs: perag initialization should only touch
m_ag_max_usable for AG 0
8da6f7fbe43c xfs: update i_size after unwritten conversion in dio completion
a9eac76e958b xfs: report zeroed or not correctly in xfs_zero_range()
67d51bdcc9f4 fs/xfs: Use %pS printk format for direct addresses
2bf3122f2130 xfs: evict CoW fork extents when performing finsert/fcollapse
a58a0826656d xfs: don't unconditionally clear the reflink flag on
zero-block files
c61e905e0ee2 iomap_dio_rw: Allocate AIO completion queue before submitting dio
7610595830bb pkcs7: Prevent NULL pointer dereference, since sinfo is
not always set.
24a33a0c96f3 KEYS: don't let add_key() update an uninstantiated key
ad4aa448c9b2 FS-Cache: fix dereference of NULL user_key_payload
f45b8fe12221 KEYS: Fix race between updating and finding a negative key
e56be12012c2 ecryptfs: fix dereference of NULL user_key_payload
363ce0b01fe0 fscrypt: fix dereference of NULL user_key_payload
cc757d55c903 lib/digsig: fix dereference of NULL user_key_payload
f5e97214207f x86/microcode/intel: Disable late loading on model 79
7b5e405b7878 Revert "tools/power turbostat: stop migrating, unless '-m'"
8b1e10789c84 KEYS: encrypted: fix dereference of NULL user_key_payload
a258a35a9930 mm: page_vma_mapped: ensure pmd is loaded with READ_ONCE
outside of lock
e47a56cbf519 usb: xhci: Handle error condition in xhci_stop_device()
d53911e63388 usb: xhci: Reset halted endpoint if trb is noop
d1120fe38b3f xhci: Cleanup current_cmd in xhci_cleanup_command_queue()
301d332138d2 xhci: Identify USB 3.1 capable hosts by their port
protocol capability
015e94ead900 usb: hub: Allow reset retry for USB2 devices on connect bounce
1916547b28bd usb: quirks: add quirk for WORLDE MINI MIDI keyboard
e3a038930502 usb: cdc_acm: Add quirk for Elatec TWN3
c2110c8dea7a USB: serial: metro-usb: add MS7820 device id
775462fd5c53 USB: core: fix out-of-bounds access bug in usb_get_bos_descriptor()
a9fdf6354267 USB: devio: Revert "USB: devio: Don't corrupt user memory"

However, you mentioned cp210x, and I noticed related changes in 4.13.8:

e21045a22395 USB: serial: console: fix use-after-free after failed setup
6c7cb458405e USB: serial: console: fix use-after-free on disconnect
4b3e3c7282d6 USB: serial: qcserial: add Dell DW5818, DW5819
c796da1d110f USB: serial: option: add support for TP-Link LTE module
e7e0b4b39663 USB: serial: cp210x: add support for ELV TFD500
1ae2c690f967 USB: serial: cp210x: fix partnum regression
78a02c93648e USB: serial: ftdi_sio: add id for Cypress WICED dev board

You could try reverting those seven, this could point to your forked driver
if it makes a difference.

       Arnd
