Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io1-f67.google.com ([209.85.166.67]:43030 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727053AbeIZBFZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Sep 2018 21:05:25 -0400
Received: by mail-io1-f67.google.com with SMTP id y10-v6so21288159ioa.10
        for <linux-nfs@vger.kernel.org>; Tue, 25 Sep 2018 11:56:29 -0700 (PDT)
MIME-Version: 1.0
References: <CAMBWrQ=xMMsHxSP8uw_H3KkMK9tUQWLYjt8yAQmFm8NDLD7pyQ@mail.gmail.com>
 <20180917211504.GA21269@fieldses.org> <CAMBWrQm2QRKNARwUf7pG_fG_ROcwXmT1PLfw5Y0ewhXzB9EqYA@mail.gmail.com>
 <20180917220107.GB21269@fieldses.org> <CAMBWrQmRtPHOFbiMsz2YAn-yQXCYjRBqq0zLJUB7snPg2MQ+tA@mail.gmail.com>
 <CAMBWrQmipZs4rwOUMhH59nHiWqyAcX7qsBG51ZWMYxWKzFZ47Q@mail.gmail.com>
 <20180918181901.GC1218@fieldses.org> <CAMBWrQmLDwhESALcH2kamrRr4VhRsgVP0kAMeiE2J0uubcfNNw@mail.gmail.com>
 <20180919200214.GB14422@fieldses.org> <CAMBWrQkQTzRj5RtqDWRen2YYKzaU_cewTu5UkUMD2Ysmd9wHkA@mail.gmail.com>
 <20180920183950.GA26850@fieldses.org> <CAMBWrQmUwmFenuxhs_jYX90R8ZgQ7+8QbWm=FpJrp7yxEwNFCw@mail.gmail.com>
In-Reply-To: <CAMBWrQmUwmFenuxhs_jYX90R8ZgQ7+8QbWm=FpJrp7yxEwNFCw@mail.gmail.com>
From: Stan Hu <stanhu@gmail.com>
Date: Tue, 25 Sep 2018 11:56:16 -0700
Message-ID: <CAMBWrQnKgmN83wmo35pVh26psEQagk0EWEm8KRJwutzmtmwcqg@mail.gmail.com>
Subject: Re: Stale data after file is renamed while another process has an
 open file handle
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

