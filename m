Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:39521 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754508AbbCBUP4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Mar 2015 15:15:56 -0500
Received: by igdh15 with SMTP id h15so20582160igd.4
        for <linux-nfs@vger.kernel.org>; Mon, 02 Mar 2015 12:15:55 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 2 Mar 2015 15:15:55 -0500
Message-ID: <CAN-5tyEYVSNeBzN8Ok=vmjxrMj-fhYQSL=ny4rqvx4r5TQNLyg@mail.gmail.com>
Subject: buggy CLOSE in the "testing" branch
From: Olga Kornievskaia <aglo@umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I'm experiencing that CLOSE uses a delegation stateid instead of the
open stateid which I think is what the spec says. Server replies with
BAD_STATEID.

Is this a bug or did I misread the spec? Thanks.
