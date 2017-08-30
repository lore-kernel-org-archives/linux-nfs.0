Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751485AbdH3LvJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 07:51:09 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 13BD9356D0
        for <linux-nfs@vger.kernel.org>; Wed, 30 Aug 2017 11:51:09 +0000 (UTC)
Message-ID: <1504093866.10850.1.camel@redhat.com>
Subject: [PATCH 0/7] Move nfs.conf to a shared library
From: Justin Mitchell <jumitche@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 30 Aug 2017 12:51:06 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A series of small patches to nfs-utils and libnfsidmap in 
part to continue my work into making an API for accessing
nfs.conf and its related config files, but also to address
issues brought to light by my previous patches.

nfs-utils and libnfsidmap were using almost identical code
to parse their config files, with identical function definitions,
which was unmasked when the prototypes changed on one set.

A problem with spaces in config arguments was recently highlighted,
this has already been fixed by my previous cleanups in nfs-utils
but not in libnfsidmap where it was reported.

Moving the config parsing code out to a shared library fixes both
of these issues with minimal code changes. I appreciate that the 
API this library presents is less than ideal, it was left this way
to reduce code changes at this point, and i welcome suggestions for
a sympathetic approach to improving it.


