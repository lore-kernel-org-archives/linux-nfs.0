Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251]:48631 "EHLO
	moving-picture.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755555Ab1FBNiA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2011 09:38:00 -0400
Message-ID: <4DE79236.1080808@moving-picture.com>
Date: Thu, 02 Jun 2011 14:37:58 +0100
From: James Pearson <james-p@moving-picture.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: How to control the order of different export options for different
 client formats?
References: <4DD2A084.1040905@moving-picture.com> <20110518080106.1159c5b8@notabene.brown> <4DD39D39.7010805@moving-picture.com> <20110518162050.GB16835@fieldses.org> <4DD66EC6.7090706@moving-picture.com> <20110520164147.GA11176@fieldses.org>
In-Reply-To: <20110520164147.GA11176@fieldses.org>
Content-Type: multipart/mixed;
 boundary="------------080802010100050109070500"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------080802010100050109070500
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> 
> But could we just combine this with the previous section--and make sure
> the different possibilities are listed there in the correct priority
> order to start off with.
> 
> That'd also mean adding a new subsection for the "anonymous" case.

OK - how about the attached patch?

James Pearson

--------------080802010100050109070500
Content-Type: text/plain;
 name="exports.man.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="exports.man.patch"

--- exports.man.dist	2010-09-28 13:24:16.000000000 +0100
+++ exports.man	2011-06-02 14:19:26.434486000 +0100
@@ -48,19 +48,6 @@
 This is the most common format. You may specify a host either by an
 abbreviated name recognized be the resolver, the fully qualified domain
 name, or an IP address.
-.IP "netgroups
-NIS netgroups may be given as
-.IR @group .
-Only the host part of each
-netgroup members is consider in checking for membership.  Empty host
-parts or those containing a single dash (\-) are ignored.
-.IP "wildcards
-Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
-This can be used to make the \fIexports\fR file more compact; for instance,
-\fI*.cs.foo.edu\fR matches all hosts in the domain
-\fIcs.foo.edu\fR.  As these characters also match the dots in a domain
-name, the given pattern will also match all hosts within any subdomain
-of \fIcs.foo.edu\fR.
 .IP "IP networks
 You can also export directories to all hosts on an IP (sub-) network
 simultaneously. This is done by specifying an IP address and netmask pair
@@ -72,6 +59,25 @@
 to the network base IPv4 address results in identical subnetworks with 10 bits of
 host. Wildcard characters generally do not work on IP addresses, though they
 may work by accident when reverse DNS lookups fail.
+.IP "wildcards
+Machine names may contain the wildcard characters \fI*\fR and \fI?\fR.
+This can be used to make the \fIexports\fR file more compact; for instance,
+\fI*.cs.foo.edu\fR matches all hosts in the domain
+\fIcs.foo.edu\fR.  As these characters also match the dots in a domain
+name, the given pattern will also match all hosts within any subdomain
+of \fIcs.foo.edu\fR.
+.IP "netgroups
+NIS netgroups may be given as
+.IR @group .
+Only the host part of each
+netgroup members is consider in checking for membership.  Empty host
+parts or those containing a single dash (\-) are ignored.
+.IP "anonymous
+This is specified by a single
+.I *
+character (not to be confused with the
+.I wildcard
+entry above) and will match all clients.
 '''.TP
 '''.B =public
 '''This is a special ``hostname'' that identifies the given directory name
@@ -92,6 +98,12 @@
 '''.B \-\-public\-root
 '''option. Multiple specifications of a public root will be ignored.
 .PP
+If a client matches more than one of the specifications above, then
+the first match from the above list order takes precedence - regardless of
+the order they appear on the export line. However, if a client matches
+more than one of the same type of specification (e.g. two netgroups),
+then the first match from the order they appear on the export line takes
+precedence.
 .SS RPCSEC_GSS security
 You may use the special strings "gss/krb5", "gss/krb5i", or "gss/krb5p"
 to restrict access to clients using rpcsec_gss security.  However, this

--------------080802010100050109070500--
