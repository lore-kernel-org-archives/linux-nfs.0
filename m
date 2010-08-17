Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705Ab0HQTin (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Aug 2010 15:38:43 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o7HJchS1021315
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 15:38:43 -0400
Received: from fathat.boston.devel.redhat.com (fathat.boston.devel.redhat.com [10.16.60.125])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id o7HJcgrj011196
	for <linux-nfs@vger.kernel.org>; Tue, 17 Aug 2010 15:38:43 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/2] Support for Numeric Representations of UIDs and GIDs. 
Date: Tue, 17 Aug 2010 15:38:43 -0400
Message-Id: <1282073925-18707-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

In recent NFS v2/v3 to v4 transitions, one of the sticking 
points have been that fact v4 uses strings in the format
of "user@domain" instead of 32bit integers for uids and 
gids.

When the string can not be mapped, its mapped to the 'nobody'
user which is not optimal for things like backup servers and
such where the ids will not be know by both sides.

So this patch series enables the server to send out numeric 
string of uids and gids that do not have the '@domain' part.
The series also adds functionality to the client that parse these
type of strings and will use the numeric representation
of the ids iff the id exists on the client, which is 
sightly different that Solaris. Solaris dose not have that
"id must exist" restriction.

Steve Dickson (2):
  Teach clients to map numeric strings into valid uids and gids.
  Add server support to use of numeric strings for uid and gids.

 utils/idmapd/idmapd.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 51 insertions(+), 1 deletions(-)

