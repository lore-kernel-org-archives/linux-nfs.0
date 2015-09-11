Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:41219 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655AbbIKPGW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2015 11:06:22 -0400
Date: Fri, 11 Sep 2015 16:06:13 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-arm-kernel@lists.infradead.org
Subject: Re: NFS/TCP/IPv6 acting strangely in 4.2
Message-ID: <20150911150613.GR21084@n2100.arm.linux.org.uk>
References: <20150911113839.GO21084@n2100.arm.linux.org.uk>
 <1441976691.4619.58.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150911143347.GQ21084@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20150911143347.GQ21084@n2100.arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 11, 2015 at 03:33:47PM +0100, Russell King - ARM Linux wrote:
> It looks like 0c78789e3a030615c6650fde89546cadf40ec2cc might be relevant
> too, but I don't see that solving the multiple _concurrent_ connection
> attempts with the same port number - presumably it's somehow trying to
> make the same socket repeatedly connect despite a previous connection
> being in progress, which would have nothing to do with cleaning up a
> previous attempt.

As I suspected, applying the above commit in addition does not solve the
problem, I still see the same behaviour: SYN SYNACK SYN RSTACK, SYN
SYNACK SYN RSTACK, and eventual SYN storms.

I do have this captured as well:

2558   0.834316 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1053655487 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60001 TSecr=0 WS=128
2559   0.834572 n2100 -> armada388 TCP nfs→rpasswd [SYN, ACK] Seq=3076611574 Ack=1053655488 Win=28560 Len=0 MSS=1440 SACK_PERM=1 TSval=869622246 TSecr=60001 WS=64
2560   0.834666 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1054228544 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60005 TSecr=0 WS=128
2561   0.834895 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622246 TSecr=60001

The packet at 2561 looks wrong to me - this doesn't follow what I know
would be the standard TCP setup of syn, synack, ack, because that final
ack is in the wrong direction.

2562   0.834965 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1054228969 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60005 TSecr=0 WS=128
2563   0.835156 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622246 TSecr=60001
2564   0.835218 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1054229397 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60005 TSecr=0 WS=128
2565   0.835420 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622246 TSecr=60001
2566   0.835488 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1054229824 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60005 TSecr=0 WS=128
2567   0.835681 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622246 TSecr=60001
2568   0.835753 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1054230261 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60005 TSecr=0 WS=128
2569   0.835971 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622246 TSecr=60001
...
2701   0.858226 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622247 TSecr=60001
2702   0.858270 n2100 -> armada388 TCP [TCP Dup ACK 2701#1] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622247 TSecr=60001
2703   0.858283 n2100 -> armada388 TCP [TCP Dup ACK 2701#2] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622247 TSecr=60001
...
2772   0.859373 n2100 -> armada388 TCP [TCP Dup ACK 2701#71] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622248 TSecr=60001
2773   0.892349 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1054273361 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60005 TSecr=0 WS=128
2774   0.892725 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622252 TSecr=60001
...
2960   0.979230 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622259 TSecr=60001
2961   0.979278 n2100 -> armada388 TCP [TCP Dup ACK 2960#1] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622259 TSecr=60001
2962   0.979291 n2100 -> armada388 TCP [TCP Dup ACK 2960#2] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622259 TSecr=60001
...
3030   0.980329 n2100 -> armada388 TCP [TCP Dup ACK 2960#70] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622260 TSecr=60001
3031   0.980343 n2100 -> armada388 TCP [TCP Dup ACK 2960#71] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622260 TSecr=60001
3032   0.989005 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1056293352 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60018 TSecr=0 WS=128
3033   0.989462 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622262 TSecr=60001
...
3206   1.011270 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1056917791 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60022 TSecr=0 WS=128
3207   1.011721 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622263 TSecr=60001
3208   1.011765 n2100 -> armada388 TCP [TCP Dup ACK 3207#1] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622263 TSecr=60001
3209   1.011779 n2100 -> armada388 TCP [TCP Dup ACK 3207#2] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622263 TSecr=60001
...
3247   1.012250 n2100 -> armada388 TCP [TCP Dup ACK 3207#40] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622264 TSecr=60001
3248   1.012528 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1056918216 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60022 TSecr=0 WS=128
3249   1.012881 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622264 TSecr=60001
... eventually ...
3483   1.096726 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1057880967 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60028 TSecr=0 WS=128
3484   1.099249 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622271 TSecr=60001
3485   1.099368 n2100 -> armada388 TCP [TCP Dup ACK 3484#1] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622271 TSecr=60001
3486   1.099401 n2100 -> armada388 TCP [TCP Dup ACK 3484#2] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622271 TSecr=60001
...
3541   1.100250 n2100 -> armada388 TCP [TCP Dup ACK 3484#57] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622272 TSecr=60001
3542   1.100261 n2100 -> armada388 TCP [TCP Dup ACK 3484#58] nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622272 TSecr=60001
3543   1.109405 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1057881400 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60028 TSecr=0 WS=128
3544   1.109778 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622274 TSecr=60001
...
3555   1.111223 armada388 -> n2100 TCP [TCP Port numbers reused] rpasswd→nfs [SYN] Seq=1057883994 Win=28800 Len=0 MSS=1440 SACK_PERM=1 TSval=60028 TSecr=0 WS=128
3556   1.111403 n2100 -> armada388 TCP nfs→rpasswd [ACK] Seq=3076611575 Ack=1053655488 Win=28560 Len=0 TSval=869622274 TSecr=60001
...
3604   1.190099 armada388 -> n2100 TCP rpasswd→nfs [RST] Seq=1053655488 Win=0 Len=0

It looks like the SYNs for the new connections provoke ACKs from an
existing connection but obviously different sequence number.  That
looks weird, shouldn't they be provoking resets or being ignored?

What if these SYN packets were spoofed from half-way across the net?
It seems like it could be used to provoke ACK traffic (with valid
sequence numbers) against a potential victim.  However, that's the
3.x kernel which is responding with those ACKs - let's put that to
one side for the time being until there's an answer for the NFS
problem.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
