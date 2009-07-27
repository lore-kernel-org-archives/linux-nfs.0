From: Daniel J Blueman <daniel.blueman@gmail.com>
Subject: [2.6.31-rc4] nfs4 writecount warning...
Date: Mon, 27 Jul 2009 22:49:03 +0100
Message-ID: <6278d2220907271449l38609680n943875d2672da20f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux Kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755206AbZG0VtG@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After two days uptime on my NFS4 server with 2.6.31-rc4 and a few
2.6.28 clients, I hit the file write-count
WARN_ON(f->f_mnt_write_state != 0) in file_take_write() in the
nfsd4_open path [1].

I can't find this reported elsewhere; let me know if it's preferred in
bugzilla.kernel.org etc.

Thanks,
  Daniel

--- [1]

------------[ cut here ]------------

WARNING: at include/linux/fs.h:953 nfsd4_process_open2+0x9c3/0xc90()

Hardware name: OEM

Modules linked in: coretemp w83627ehf hwmon_vid ath9k
snd_hda_codec_realtek mac80211 led_class ath snd_hda_intel
snd_hda_codec snd_pcm snd_timer snd pl2303 soundcore snd_page_alloc

Pid: 2970, comm: nfsd Tainted: G        W  2.6.31-rc4-274sd #1

Call Trace:

 [<ffffffff81190413>] ? nfsd4_process_open2+0x9c3/0xc90

 [<ffffffff810490f8>] warn_slowpath_common+0x78/0xd0

 [<ffffffff8104915f>] warn_slowpath_null+0xf/0x20

 [<ffffffff81190413>] nfsd4_process_open2+0x9c3/0xc90

 [<ffffffff8118420f>] ? do_open_lookup+0x28f/0x300

 [<ffffffff811844b9>] nfsd4_open+0x239/0x420

 [<ffffffff81183c67>] nfsd4_proc_compound+0x2d7/0x530

 [<ffffffff81172115>] nfsd_dispatch+0x115/0x260

 [<ffffffff813f3d12>] svc_process+0x492/0x800

 [<ffffffff8142e507>] ? down_read+0x77/0x80

 [<ffffffff81172740>] ? nfsd+0x0/0x160

 [<ffffffff8117281d>] nfsd+0xdd/0x160

 [<ffffffff81062c9e>] kthread+0x9e/0xb0

 [<ffffffff8100ce9a>] child_rip+0xa/0x20

 [<ffffffff8100c83c>] ? restore_args+0x0/0x30

 [<ffffffff81062c00>] ? kthread+0x0/0xb0

 [<ffffffff8100ce90>] ? child_rip+0x0/0x20

---[ end trace 8ecb5c2eb0ae54d8 ]---

-- 
Daniel J Blueman
