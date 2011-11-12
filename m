Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.12.86]:47980 "EHLO
	tombraider.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751651Ab1KLStd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Nov 2011 13:49:33 -0500
Date: Sat, 12 Nov 2011 13:49:24 -0500
From: Jim Rees <rees@umich.edu>
To: Lukas Razik <linux@razik.name>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [BUG?] Maybe NFS bug since 2.6.37 on SPARC64
Message-ID: <20111112184804.GA25581@umich.edu>
References: <39983D1A-70A8-49A1-A4E2-926637780F75@oracle.com>
 <1320399858.11675.YahooMailNeo@web24703.mail.ird.yahoo.com>
 <06799B7D-54CD-41D8-934A-F9C78B23677C@oracle.com>
 <1320450001.87605.YahooMailNeo@web24706.mail.ird.yahoo.com>
 <1320455965.2750.9.camel@lade.trondhjem.org>
 <1320459252.59518.YahooMailNeo@web24716.mail.ird.yahoo.com>
 <1320460311.2750.21.camel@lade.trondhjem.org>
 <1320465106.61111.YahooMailNeo@web24710.mail.ird.yahoo.com>
 <20111105130517.GA16090@umich.edu>
 <1321097734.7117.YahooMailNeo@web24701.mail.ird.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1321097734.7117.YahooMailNeo@web24701.mail.ird.yahoo.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Lukas Razik wrote:

  I've connected the systems directly (without a switch between them).
  It seems that the problem came from the switch because now the newer kernels also mount their NFSROOTs during start up without problems.
  
  Assuming that the ports of the switch really run in STP mode - two questions:
  1. Is it unusual that the ports of a switch where computers are connected to run in STP mode?
  2. If that's not unusual: Wouldn't it be useful if the new linux kernels could mount an NFSROOT even when the system is plugged into an STP port?

STP ports are normally won't start forwarding packets until they have
decided there are no loops.  The usual way to configure a data center switch
is to leave the trunks in this configuration, and set portfast on the ports
that have end systems (like your server) on them.  I think "portfast" is the
Cisco term for this, other vendors might call it something else.  Portfast
ports are still running stp, they just start out in forwarding mode and only
switch to learning mode if they detect a problem.

The question for us is how long should an nfsroot client wait for the server
to reply.  It sounds like the client used to wait longer than it does now.
It seems to me the client should wait at least 90 seconds so that the
situation you're in (servers on non-portfast ports) will work.  I would
think they should wait indefinitely, since there's not much else they can
do.
