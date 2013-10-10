Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-1.desy.de ([131.169.56.154]:55061 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751948Ab3JJPL4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Oct 2013 11:11:56 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 5430C280930
	for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 17:11:55 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 8AD1A13E99
	for <linux-nfs@vger.kernel.org>; Thu, 10 Oct 2013 17:11:52 +0200 (MEST)
Date: Thu, 10 Oct 2013 17:11:52 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Weston Andros Adamson <dros@netapp.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>,
        Andy Adamson <William.Adamson@netapp.com>,
        Steve Dickson <steved@redhat.com>
Message-ID: <1777495627.591249.1381417912773.JavaMail.zimbra@desy.de>
In-Reply-To: <1732606875.591017.1381416532236.JavaMail.zimbra@desy.de>
References: <1667669326.580689.1381351712928.JavaMail.zimbra@desy.de> <1232423514.586176.1381399016371.JavaMail.zimbra@desy.de> <4A5C5668-CBB0-444B-A726-BF6E0D22866B@netapp.com> <FB2C39E8-D3A1-46E4-83A8-1EC9D5EB327B@netapp.com> <1732606875.591017.1381416532236.JavaMail.zimbra@desy.de>
Subject: Re: DoS with NFSv4.1 client
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



This is probably a question to IEFT working group, but anyway.
If my layout has a flag 'return-on-close' and open state id
is not valid any more should client expect layout to be still valid?

Tigran.

----- Original Message -----
> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> To: "Weston Andros Adamson" <dros@netapp.com>
> Cc: "linux-nfs" <linux-nfs@vger.kernel.org>, "Andy Adamson" <William.Adamson@netapp.com>, "Steve Dickson"
> <steved@redhat.com>
> Sent: Thursday, October 10, 2013 4:48:52 PM
> Subject: Re: DoS with NFSv4.1 client
> 
> 
> 
> ----- Original Message -----
> > From: "Weston Andros Adamson" <dros@netapp.com>
> > To: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> > Cc: "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>, "Andy
> > Adamson" <William.Adamson@netapp.com>, "Steve
> > Dickson" <steved@redhat.com>
> > Sent: Thursday, October 10, 2013 4:35:25 PM
> > Subject: Re: DoS with NFSv4.1 client
> > 
> > Well, it'd be nice not to loop forever, but my question remains, is this
> > due
> > to a server bug (the DS not knowing about new stateid from MDS)?
> > 
> 
> Up to now, we have pushed open state id to the DS only on LAYOUTGET.
> This have to be changed, as the behaviour is not spec compliant.
> 
> Tigran.
> 
> > -dros
> > 
> > On Oct 10, 2013, at 10:14 AM, Weston Andros Adamson <dros@netapp.com>
> > wrote:
> > 
> > > So is this a server bug? It seems like the client is behaving
> > > correctly...
> > > 
> > > -dros
> > > 
> > > On Oct 10, 2013, at 5:56 AM, "Mkrtchyan, Tigran"
> > > <tigran.mkrtchyan@desy.de>
> > > wrote:
> > > 
> > >> 
> > >> 
> > >> Today we was 'luck' to have such situation at day time.
> > >> Here is what happens:
> > >> 
> > >> The client sends an OPEN and gets an open state id.
> > >> This is followed by LAYOUTGET ... and READ to DS.
> > >> At some point, server returns back BAD_STATEID.
> > >> This triggers client to issue a new OPEN and use
> > >> new open stateid with READ request to DS. As new
> > >> stateid is not known to DS, it keeps returning
> > >> BAD_STATEID and becomes an infinite loop.
> > >> 
> > >> Regards,
> > >>  Tigran.
> > >> 
> > >> 
> > >> 
> > >> ----- Original Message -----
> > >>> From: "Tigran Mkrtchyan" <tigran.mkrtchyan@desy.de>
> > >>> To: linux-nfs@vger.kernel.org
> > >>> Cc: "Andy Adamson" <william.adamson@netapp.com>, "Steve Dickson"
> > >>> <steved@redhat.com>
> > >>> Sent: Wednesday, October 9, 2013 10:48:32 PM
> > >>> Subject: DoS with NFSv4.1 client
> > >>> 
> > >>> 
> > >>> Hi,
> > >>> 
> > >>> last night we got a DoS attack with one of the NFS clients.
> > >>> The farm node, which was accessing data with pNFS,
> > >>> went mad and have tried to kill dCache NFS server. As usually
> > >>> this have happened over night and we was not able to
> > >>> get a network traffic or bump the debug level.
> > >>> 
> > >>> The symptoms are:
> > >>> 
> > >>> client starts to bombard the MDS with OPEN requests. As we see
> > >>> state created on the server side, the requests was processed by
> > >>> server. Nevertheless, for some reason, client did not like it. Here
> > >>> is the result of mountstats:
> > >>> 
> > >>> OPEN:
> > >>> 	17087065 ops (99%) 	1 retrans (0%) 	0 major timeouts
> > >>> 	avg bytes sent per op: 356	avg bytes received per op: 455
> > >>> 	backlog wait: 0.014707 	RTT: 4.535704 	total execute time: 4.574094
> > >>> 	(milliseconds)
> > >>> CLOSE:
> > >>> 	290 ops (0%) 	0 retrans (0%) 	0 major timeouts
> > >>> 	avg bytes sent per op: 247	avg bytes received per op: 173
> > >>> 	backlog wait: 308.827586 	RTT: 1748.479310 	total execute time:
> > >>> 	2057.365517
> > >>> 	(milliseconds)
> > >>> 
> > >>> 
> > >>> As you can see there is a quite a big difference between number of open
> > >>> and
> > >>> close requests.
> > >>> The same picture we can see on the server side as well:
> > >>> 
> > >>> NFSServerV41 Stats:                   average±stderr(ns)       min(ns)
> > >>> max(ns)            Sampes
> > >>> DESTROY_SESSION                          26056±4511.89        13000
> > >>> 97000                17
> > >>> OPEN                                    1197297±  0.00       816000
> > >>> 31924558000          54398533
> > >>> RESTOREFH                                     0±  0.00            0
> > >>> 25018778000          54398533
> > >>> SEQUENCE                                   1000±  0.00         1000
> > >>> 26066722000          55601046
> > >>> LOOKUP                                  4607959±  0.00       375000
> > >>> 26977455000             32118
> > >>> GETDEVICEINFO                             13158±100.88         4000
> > >>> 655000             11378
> > >>> CLOSE                                  16236211±  0.00         5000
> > >>> 21021819000             20420
> > >>> LAYOUTGET                             271736361±  0.00     10003000
> > >>> 68414723000             21095
> > >>> 
> > >>> The last column is the number of requests.
> > >>> 
> > >>> This is with RHEL6.4 as the client. By looking at the code,
> > >>> I can see a loop at nfs4proc.c#nfs4_do_open() which can be
> > >>> the cause of the problem. Nevertheless, I can't
> > >>> fine any reason why this look turned into an 'infinite' one.
> > >>> 
> > >>> At the and our server ran out of memory and we have returned
> > >>> NFSERR_SERVERFAULT to the client. This triggered client to
> > >>> reestablish the session and all open state ids was
> > >>> invalidated and cleaned up.
> > >>> 
> > >>> I am still trying to reproduce this behavior (on client
> > >>> and server) and any hint is welcome.
> > >>> 
> > >>> Tigran.
> > >>> --
> > >>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > >>> the body of a message to majordomo@vger.kernel.org
> > >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > >>> 
> > >> --
> > >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > >> the body of a message to majordomo@vger.kernel.org
> > >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
