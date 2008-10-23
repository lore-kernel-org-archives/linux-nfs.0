From: Michel Lespinasse <walken-Y93EPB1FQwg@public.gmane.org>
Subject: Re: Fwd: NFS 5-minute hangs upon S3 resume using 2.6.27 client
Date: Thu, 23 Oct 2008 12:52:31 -0700
Message-ID: <20081023195231.GA2090@zoy.org>
References: <20081023040231.GA13512@zoy.org> <1224776207.7625.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server.lespinasse.org ([64.142.28.226]:49493 "EHLO
	server.lespinasse.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758850AbYJWTwd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Oct 2008 15:52:33 -0400
In-Reply-To: <1224776207.7625.7.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

On Thu, Oct 23, 2008 at 11:36:47AM -0400, Trond Myklebust wrote:
> Does the appended patch make a difference?
> 
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Thu, 23 Oct 2008 11:33:59 -0400
> SUNRPC: Respond promptly to server TCP resets

I applied it over a 2.6.27.3 base, suspended the client for 40 minutes
and resumed it, logging what happens from the server side. The resume
went like this:

12:38:53.692785 IP client.329262748 > server.nfs: 100 getattr [|nfs]
12:38:53.699885 arp who-has client tell server
12:38:54.123793 IP client.329262748 > server.nfs: 100 getattr [|nfs]
12:38:54.695888 arp who-has client tell server
12:38:54.696011 arp reply client is-at 00:19:d1:54:0e:39 (oui Unknown)
12:38:54.696020 IP server.nfs > client.882: R 2944642919:2944642919(0) win 0
12:38:54.696024 IP server.nfs > client.882: R 2944642919:2944642919(0) win 0

(I'm still concerned about the 3 second delay here...)

12:38:57.695956 IP client.2 > server.nfs: 0 null
12:38:57.696004 IP server.nfs > client.2: reply ERR 0 null
12:38:57.696133 IP client.882 > server.nfs: . ack 931551254 win 183 <nop,nop,timestamp 448858 1116460165>
12:38:57.696159 IP client.362817180 > server.nfs: 100 getattr [|nfs]
12:38:57.696179 IP server.nfs > client.882: . ack 64732 win 91 <nop,nop,timestamp 1116460165 448858>
12:38:57.696189 IP client.346039964 > server.nfs: 100 getattr [|nfs]
12:38:57.696205 IP server.nfs > client.882: . ack 64832 win 91 <nop,nop,timestamp 1116460165 448858>
12:38:57.696294 IP client.329262748 > server.nfs: 300 getattr [|nfs]
12:38:57.696307 IP server.nfs > client.882: . ack 65132 win 108 <nop,nop,timestamp 1116460165 448858>
12:38:57.765764 IP server.nfs > client.362817180: reply ok 116 getattr [|nfs]
12:38:57.765833 IP server.nfs > client.346039964: reply ok 116 getattr [|nfs]
12:38:57.765879 IP client.882 > server.nfs: . ack 931551370 win 183 <nop,nop,timestamp 448875 1116460182>
12:38:57.765903 IP server.nfs > client.329262748: reply ok 116 getattr [|nfs]
12:38:57.765909 IP client.882 > server.nfs: . ack 931551486 win 183 <nop,nop,timestamp 448875 1116460182>
12:38:57.765933 IP server.nfs > client.379594396: reply ok 116
12:38:57.765953 IP client.882 > server.nfs: . ack 931551602 win 183 <nop,nop,timestamp 448875 1116460182>
12:38:57.766008 IP client.882 > server.nfs: . ack 931551718 win 183 <nop,nop,timestamp 448875 1116460182>
12:38:57.766058 IP server.nfs > client.396371612: reply ok 116
12:38:57.766108 IP client.413148828 > server.nfs: 100 getattr [|nfs]
12:38:57.766149 IP server.nfs > client.882: . ack 65232 win 108 <nop,nop,timestamp 1116460182 448875>
12:38:57.766176 IP server.nfs > client.413148828: reply ok 116 getattr [|nfs]
12:38:57.766274 IP client.882 > server.nfs: . ack 931551950 win 183 <nop,nop,timestamp 448875 1116460182>
12:38:57.769130 IP client.429926044 > server.nfs: 100 getattr [|nfs]
12:38:57.769188 IP server.nfs > client.429926044: reply ok 116 getattr [|nfs]
12:38:57.769418 IP client.446703260 > server.nfs: 100 getattr [|nfs]
12:38:57.769473 IP server.nfs > client.446703260: reply ok 116 getattr [|nfs]

I'll have more results tonight when I try resuming again. If the delay
goes to 6 seconds then the issue is probably still there... I'll report
here either way.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.
