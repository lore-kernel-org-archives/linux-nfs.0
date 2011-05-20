Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:58839 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933714Ab1ETNiR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 May 2011 09:38:17 -0400
Message-ID: <4DD66EC6.7090706@moving-picture.com>
Date: Fri, 20 May 2011 14:38:14 +0100
From: James Pearson <james-p@moving-picture.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: How to control the order of different export options for different
 client formats?
References: <4DD2A084.1040905@moving-picture.com> <20110518080106.1159c5b8@notabene.brown> <4DD39D39.7010805@moving-picture.com> <20110518162050.GB16835@fieldses.org>
In-Reply-To: <20110518162050.GB16835@fieldses.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
>>Having a priority option would be a very good idea - and may be in
>>the meantime the exports man page should be updated with info about
>>the current priority ordering?
> 
> 
> Sounds good.  Could you send in a patch?

Here's an attempt - based on the info from Max Matveev <makc@redhat.com> 
earlier in this thread

James Pearson

--- exports.man.dist    2010-09-28 13:24:16.000000000 +0100
+++ exports.man 2011-05-20 14:29:45.555314605 +0100
@@ -92,6 +92,11 @@
  '''.B \-\-public\-root
  '''option. Multiple specifications of a public root will be ignored.
  .PP
+.SS Matched Client Priories
+The order in which the different \fIMachine Name Formats\fR are matched
+against clients is in the priority order: \fIhostname, IP address or 
networks,
+wildcards, netgroup and anonymous\fR. Entries at the same level are matched
+in the same order in which they appear in \fI/etc/exports\fR.
  .SS RPCSEC_GSS security
  You may use the special strings "gss/krb5", "gss/krb5i", or "gss/krb5p"
  to restrict access to clients using rpcsec_gss security.  However, this



