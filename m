Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:45297 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757485Ab1KQNNu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Nov 2011 08:13:50 -0500
Message-ID: <4EC50882.2080803@Calva.COM>
Date: Thu, 17 Nov 2011 14:13:38 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>
CC: Jim Rees <rees@umich.edu>, Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
References: <4EC3FD8B.6000705@calvaedi.com>	<20111116144718.78b2e288@corrin.poochiereds.net>	<20111116234434.GA12882@umich.edu>	<20111116203119.1d9c0dd6@corrin.poochiereds.net> <20111116203810.4e1b9d28@corrin.poochiereds.net> <4EC4EA91.5070607@Calva.COM>
In-Reply-To: <4EC4EA91.5070607@Calva.COM>
Content-Type: multipart/mixed;
 boundary="------------010100050907000402030400"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010100050907000402030400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

On 17/11/11 12:05, John Hughes wrote:
> On 17/11/11 02:38, Jeff Layton wrote:
>> Note too that the gssd code distinguishes between an expired TGT and a
>> non-existent credcache. The latter will give you the error you desire
>> here. So one possibility is just to remove the credcache from /tmp in
>> this situation.
>
> Something to scan /tmp for expired credentials and zap em?  rpc.gssd 
> would communicate that to the kernel?
>
> Whadaya know, that works.
Here's a dumb perl script that could be run from, for example, .xsession 
to automatically destroy expired ticket caches.

Would need a bit of trickery to make it go away on end of session and 
something in /etc/pm/sleep.d to send it a SIGALRM when the system wakes 
from suspend or hibernate.

It has a potential race between destroying an expired ticket and a new 
ticket being granted.

I guess now I'll look at a hack to rpc.gssd for a neater way of doing this.





--------------010100050907000402030400
Content-Type: text/plain;
 name="monitor-tickets"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="monitor-tickets"

#! /usr/bin/perl -w

my $ALARMED = 0;

$SIG{ALRM} = sub { ++$ALARMED; };

use POSIX qw(mktime);

# Work out ticket expiry

# Valid starting     Expires            Service principal
# 11/17/11 10:34:23  11/17/11 20:34:23  krbtgt/CALVAEDI.COM@CALVAEDI.COM
# 	renew until 11/18/11 10:34:23
# 11/17/11 10:34:23  11/17/11 20:34:23  nfs/olympic.calvaedi.com@CALVAEDI.COM
# 	renew until 11/18/11 10:34:23
# 11/17/11 11:24:24  11/17/11 20:34:23  host/olympic.calvaedi.com@CALVAEDI.COM
# 	renew until 11/18/11 10:34:23

# Eurgh - non localised, US format dates.

sub expiry {
	local *KLIST;
	open KLIST, "/usr/bin/klist | " or return;
	my $expiry;
	while (<KLIST>) {
		if (m((\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+)  krbtgt)) {
			$expiry = mktime ($6, $5, $4, $2, $1 - 1, 100 +  $3);
			last;
		}
	}

	$expiry;
}


for (;;) {
	my $sleepytime = 60;

	my $expiry = expiry ();
	
	if (defined $expiry) {
		my $left = $expiry - time;
		if ($left <= 0) {
			# Ticket expired, zap it.  Potential race with
			# new ticket creation.
			print "Destroy expired ticket\n";
			system "/usr/bin/kdestroy";
		}
		else {
			$sleepytime = $left;
		}
	}

	if ($ALARMED) {
		$ALARMED = 0;
		next;
	}

	# If machine freezes during this sleap how long will
	# it sleep for?
	print "Sleeping for $sleepytime seconds\n";
	sleep $sleepytime;
}

--------------010100050907000402030400--
