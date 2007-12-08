From: dawid-g7DOKF3l0ejVItvQsEIGlw@public.gmane.org
Subject: Re: [NFS] Strange NFS behaviour
Date: Sun, 9 Dec 2007 00:36:50 +0100 (CET)
Message-ID: <62339.91.149.209.2.1197157010.squirrel@www.active24.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from kurier1.active24.pl ([195.78.67.20]:56300 "EHLO
	kurier1.active24.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbXLHXgy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Dec 2007 18:36:54 -0500
Received: from localhost (localhost [127.0.0.1])
	by kurier1.active24.pl (Postfix) with ESMTP id 6A13C55592
	for <linux-nfs@vger.kernel.org>; Sun,  9 Dec 2007 00:36:51 +0100 (CET)
Received: from www.active24.pl (unknown [192.168.111.78])
	by kurier1.active24.pl (Postfix) with ESMTP id 49FE54FF19
	for <linux-nfs@vger.kernel.org>; Sun,  9 Dec 2007 00:36:51 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

It looks like there is a way to workaround this problem. One can simply
list the mounted directory before the TCP connection times out (which
takes place after 4 minutes by default). Simple ls command on the mounted
path every minute should make the problem gone.

I still wonder what is the real cause of the problem and is it the client
or the server that is buggy. This problem is really annoying.

I have been trying to use settings described in "Technical Report: Using
the Linux NFS Client with Network Appliance Storage"
(www.netapp.com/tech_library/ftp/3183.pdf) with no success.

Best Regards
Dawid

> Hi!
>
> I have an NFS resource mounted from a dedicated machine NetApp FAS3050
> using NFS v3 over TCP.
> The NFS client works on SuSe Linux Enterprise Server 10 SP1, kernel ver
> 2.6.16.46-0.14-smp.
>
> When the NFS is idle for few hours, the NFS resources sometimes become
> inaccessible. Every process accessing such resource hangs.
>
> I have sniffed the NFS connection and found an interesting behaviour of
> the NFS client/server:
>
> time          src    dest    proto port numbers content
>
> 16692.276474  client server  TCP   1023 > 2049  [SYN]
> 16692.277171  server client  TCP   2049 > 1023  [SYN, ACK]
> 16692.277189  client server  TCP   1023 > 2049  [ACK]
> 16692.277197  client server  NFS   1023 > 2049  V3 ACCESS Call,
> FH:0x30ed5a16
> 16692.378613  server client  TCP   2049 > 1023  [ACK]
> 16701.285748  server client  TCP   2049 > 1023  [FIN, ACK]
> 16701.285764  client server  TCP   1023 > 2049  [FIN, ACK]
> 16701.285790  client server  TCP   1022 > 2049  [SYN]
> 16701.286497  server client  TCP   2049 > 1022  [SYN, ACK]
> 16701.286506  client server  TCP   1022 > 2049  [ACK]
> 16701.286508  server client  TCP   2049 > 1023  [ACK]
> 16701.286512  client server  TCP   1022 > 2049  V3 ACCESS Call,
> FH:0x30ed5a16
> 16701.287247  server client  TCP   2049 > 1022  [FIN, ACK]
> 16701.287257  client server  TCP   1022 > 2049  [FIN, ACK]
> 16701.287271  client server  TCP   1021 > 2049  [SYN]
>
>
> Since there was no active TCP connection to the NFS server, it has been
> established. Then, an NFS ACCESS command was sent to the server. The
> server did not answer the NFS query, but initialised the TCP connection
> close instead.
>
> After receiving [FIN, ACK] the client reconnected immediately, but this
> time on port 1002 (since 1023 is still in use at this point). Again, the
> server closed the TCP connection and another attempt was made on a new
> port number.
>
> This is not on the log, but the NFS client keeps repeating this on each of
> the port numbers in range <1023,664>. When port number 664 is reached, the
> NFS server stops answering the TCP SYN packets.
>
> This started to happen after upgrading linux from SuSe Linux 10.1
> 2.6.16.21-0.25-smp. Another thing is that there are also VxWorks clients
> using that NFS server which work fine.
>
> Do you have any idea of what is the reason for such behavior?
>
> Thanks in advance.
>
> Regards,
> Dawid Pawlata
>
> -
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


