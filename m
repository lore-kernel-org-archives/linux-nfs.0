Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from internet.csl.co.uk ([84.19.238.83]:60322 "EHLO
	internet.csl.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab1FTSaC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2011 14:30:02 -0400
Received: from csl.co.uk ([10.100.10.20])
	by internet.csl.co.uk (8.13.8/8.13.8) with ESMTP id p5KHmtXA015252
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2011 18:48:55 +0100
Received: from ediexfe01.iouk.ioroot.tld (ediexfe01.iouk.ioroot.tld [10.100.10.52])
	by csl.co.uk (8.13.1/8.13.1) with ESMTP id p5KHmrfH022917
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jun 2011 18:48:55 +0100
Subject: Thoughts on dynamic networking with NFS
From: "Colin Simpson" <Colin.Simpson@iongeo.com>
To: <linux-nfs@vger.kernel.org>
Date: Mon, 20 Jun 2011 18:48:52 +0100
Content-Type: text/plain;
	charset="utf-8"
Message-ID: <1308592132.10985.4.camel@bhac.iouk.ioroot.tld>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi

I previously posted this question to the autofs mailing list but it's
been suggested that it might be better being here. 

We now have quite a few users with linux laptops and they want to see
the standard automounts on these. But being laptops they frequently
switch subnet, jump on WiFi and VPN etc.

Most subsystems seem to play pretty well with this dynamic network
environment and are hooked into NM (with SSSD doing a good job with off
net credentials and directory services caching)

Now I know that nfs is a much harder nut to crack given its heavy in
kernel component and statefulness, but I'd have thought the present
non-dynamic behaviour is a bit of an anomaly. 

Our present workaround is to hook a script into NM that detects when on
or off lan. If going on lan to off, it will stop the autofs. If still
mounts present when stopped, it will forcibly umount them. Pretty ugly,
but better for the system than lots of dead mounts, which breaks lots of
things (and doesn't recover if connecting to a new lan IP). Going off to
on lan and starting autofs seems to recover and  see the automounts fine
(despite the previous brutality to the mount points we performed).

We of course override the automounted home dir for the laptop owner. But
they can still get to their network one via the automount when on lan
(or VPN etc). And other users can ssh into the back of these laptops
(should that be necessary) and get their automounted homedir as any
other machine would. So nicely consistent.

In our application, the main purpose of the mounts is for the user to
see their network homedir or various shared project directories. So, in
general, the only thing still looking at these mounts on a connection or
VPN dropping will be a shell or a GUI file browser.

If the shell (or whatever app) doesn't like the mounts going, it doesn't
really matter (even if it just crashes). It's better than the
alternative, locking up the system randomly if you hit hung mount point,
locking programs that hate stale mounts (rpm or yum, for example) or
leaving you with some hung app that you can't kill (esp in the GUI).
That would be a terrible user experience.

This may not be good for the system (but seems to work) and is horrible,
but what's our alternative?

It's been suggested that there is work on NFSv4 that might help with
this?

Or any other thoughts on how this might be made to work more cleanly?

Thanks


Colin


This email and any files transmitted with it are confidential and are intended solely for the use of the individual or entity to whom they are addressed.  If you are not the original recipient or the person responsible for delivering the email to the intended recipient, be advised that you have received this email in error, and that any use, dissemination, forwarding, printing, or copying of this email is strictly prohibited. If you received this email in error, please immediately notify the sender and delete the original.


