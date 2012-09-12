Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53187 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755375Ab2ILMqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Sep 2012 08:46:16 -0400
From: David Howells <dhowells@redhat.com>
To: Bryan Schumaker <bjschuma@netapp.com>
cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        Markus Rothe <markus@unixforces.net>
Subject: FWD: Kernel panic after df4c3fd716e3565c6ab83ec4b6617cc180f062a1
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Date: Wed, 12 Sep 2012 13:46:09 +0100
Message-ID: <6241.1347453969@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi Bryan,

Here's another idmapper bug, in screenshot form.  We may not yet have fixed
this as Markus said it's still present in 3.5.3.

David


--=-=-=
Content-Type: message/rfc822
Content-Disposition: inline; filename=21941

Return-Path: markus@unixforces.net
Received: from mail.corp.redhat.com [10.5.5.52]
	by warthog.procyon.org.uk with IMAP (fetchmail-6.3.21)
	for <dhowells@localhost> (single-drop); Sat, 18 Aug 2012 17:58:51 +0100 (BST)
Received: from zmta05.collab.prod.int.phx2.redhat.com (LHLO
 zmta05.collab.prod.int.phx2.redhat.com) (10.5.81.12) by
 zmail16.collab.prod.int.phx2.redhat.com with LMTP; Sat, 18 Aug 2012
 12:58:46 -0400 (EDT)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by zmta05.collab.prod.int.phx2.redhat.com (Postfix) with ESMTP id 41F3FF2530
	for <dhowells@mail.corp.redhat.com>; Sat, 18 Aug 2012 12:58:46 -0400 (EDT)
Received: from mx1.redhat.com (ext-mx14.extmail.prod.ext.phx2.redhat.com [10.5.110.19])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q7IGwjFl024991
	for <dhowells@redhat.com>; Sat, 18 Aug 2012 12:58:46 -0400
Received: from mail-vc0-f174.google.com (mail-vc0-f174.google.com [209.85.220.174])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q7IGwhXn006495
	for <dhowells@redhat.com>; Sat, 18 Aug 2012 12:58:44 -0400
Received: by vcbfk26 with SMTP id fk26so4812599vcb.33
        for <dhowells@redhat.com>; Sat, 18 Aug 2012 09:58:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20120113;
        h=mime-version:x-originating-ip:from:date:message-id:subject:to
         :content-type:x-gm-message-state;
        bh=wFZEhAVq0PDLr1K2Jk4H+PTivzCabJ6zyEJm+gr8MdI=;
        b=hYaQIH3Ro7zRI0BgT7D83hTlWqiW81IleotBF2feecRgTSREUi8MfmKQ34Jf0O4o4d
         8/UZ0vVoBhPdyCNEP5JVufY0r0WS9lVSLjpC0lX8mRkuUAbNwlwkJyJi+jgbgheMrtRj
         Wp4Sa3wO4seK/0Jr8R3R+FvfRtMN3vEcf4rw9XvDFTtv6gf2BZKfOH3FN40VmpRTXqZR
         TTMd9NRJimWLBugW2mtlvllP75/g+V0YprRJ/4HLxvBVPzYvxq819fNbiHDacCEd++Cy
         A95DrlnLaFIj8E7OegGXc2leUEnfY+fCA6NOsnXC3MQcuhmjWv6/TR7N4T4LBxmmIS/p
         H2dA==
Received: by 10.52.70.116 with SMTP id l20mr4863756vdu.74.1345309122941; Sat,
 18 Aug 2012 09:58:42 -0700 (PDT)
MIME-Version: 1.0
Received: by 10.58.136.8 with HTTP; Sat, 18 Aug 2012 09:58:12 -0700 (PDT)
X-Originating-IP: [88.152.168.191]
From: Markus Rothe <markus@unixforces.net>
Date: Sat, 18 Aug 2012 18:58:12 +0200
Message-ID: <CALi3HZpfH3Wxjd9mW9H=oku-h0zO0gceqc34D4-CbXn8USRjLw@mail.gmail.com>
Subject: Kernel panic after df4c3fd716e3565c6ab83ec4b6617cc180f062a1
To: David Howells <dhowells@redhat.com>
Content-Type: text/plain; charset=UTF-8
X-Gm-Message-State: ALoCoQnbnbDlfCnth07TUQLRli8CjYcS168DUHk4mVl7FQMnlHqBKyMEFq3U3hvkPYOD/yKMiK4H
X-RedHat-Spam-Score: -2.6  (BAYES_00,RCVD_IN_DNSWL_LOW)
X-Scanned-By: MIMEDefang 2.67 on 10.5.11.12
X-Scanned-By: MIMEDefang 2.68 on 10.5.110.19

Hello,

after upgrading from 3.5.0 to 3.5.1 I am getting a kernel panic once I
try to mount an nfs share. See [1]. Sorry, I don't know how to get the
text in this state.

I have bisected the problem to
df4c3fd716e3565c6ab83ec4b6617cc180f062a1 in linux-stable. Reverting
that patch fixes the problem for me.

Could you please check what is going on.

Thanks, Markus

[1] http://pics.mrothe.de/IMG_20120818_180356.jpg


--=-=-=--
