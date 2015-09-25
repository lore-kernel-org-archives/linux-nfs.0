Return-Path: <ffilzlnx@mindspring.com>
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Benjamin Coddington'" <bcodding@redhat.com>,
        "'Pankaj Singh'" <psingh.ait@gmail.com>
Cc: <linux-nfs@vger.kernel.org>
References: <CAPrqf91jVM8jq2-u9TBNPx4nc2pmPct-PYqGWau4mcQQOT_Lmg@mail.gmail.com> <alpine.OSX.2.19.9992.1509250914050.24831@planck.local>
In-Reply-To: <alpine.OSX.2.19.9992.1509250914050.24831@planck.local>
Subject: RE: Tool or module to test NFSv3 server scalability
Date: Fri, 25 Sep 2015 15:00:18 -0700
Message-ID: <028f01d0f7dd$91c11e50$b5435af0$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
List-ID: <linux-nfs.vger.kernel.org>

> > Hi all,
> >
> > I am new to nfs. I have a requirement to test the scalability of NFSv3.
> > To test this I would require a solution that can simulate multiple nfs
clients.
> > As its known a single TCP connection is used for communication between
> > client and server. So to increase multiple connections multiple
> > nfs-clients would be needed. Which is very costly.
> >
> > So would need some method/tool to create multiple nfs TCP connections
> > from single or few machines.
> 
> 
> Hi Pankaj, this is a fun question.
> 
> One thought I had would be to use a big block ip addresses on a linux NFS
> server, and mount the filesystem with each unique server ip address.  That
> should create a bunch of connections with only a single client and server.
> IPv6 is ideal since there's a lot of address room.
> 
> This turns out to be really easy to do if you have a linux server with
Any-IP
> support [1].
> 
> On my server, I set up a rule so that any ipv6 traffic arriving on eth0
consults
> route table 200, and set up route table 200 to route everything to the
> loopback interface:
> 
> ip -6 rule add from all iif eth0 lookup 200 ip -6 route add local default
dev lo
> table 200
> 
> Then on my client, I set a routing rule for a large local network to route
to my
> server's eth0 ipv6 real-world address:
> 
> ip -6 route add fd12:3456:789a:1::/64 via
> 2601:18b:4000:1a2a:5054:ff:fe30:a648
> 
> Now, whenever my client sends any traffic to any ip in
fd12:3456:789a:1::/64,
> it will go to my server's loopback adapter which should accept it as
though it
> had that address.
> 
> On the client we can then bash out some mounts:
> 
> for j in {1..1024}; do mkdir /mnt/v6/$(printf %x $j); done; cd /mnt/v6 for
dir in
> *; do mount \[fd12:3456:789a:1::$dir\]:/ $dir; done grep fd12 /proc/mounts
|
> wc
>    1024    6144  248022
> 
> This should cause the linux nfs client's rpc code to create a separate
> connection for each mount.

You can also do something like this using localhost addresses (I often for
testing use several different localhost addresses to simulate multiple
clients).

I used it long ago to check out some stuff with 1000 clients.

Frank


---
This email has been checked for viruses by Avast antivirus software.
https://www.avast.com/antivirus
