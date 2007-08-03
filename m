From: "Mock, JV Jason @ IS" <Jason.V.Mock@L-3Com.com>
Subject: Re: NFS Caching / Locking
Date: Fri, 3 Aug 2007 08:20:48 -0500
Message-ID: <F31FEAB987B7C2469181758C14265CFA040BBABD@gvlexch03.is.l-3com.com>
References: <F31FEAB987B7C2469181758C14265CFA040BBABB@gvlexch03.is.l-3com.com>
	<18098.54654.108131.864508@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Neil Brown" <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IGx5N-0006cn-Bh
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 06:20:57 -0700
Received: from smtpout3.l-3com.com ([166.20.84.211])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IGx5Q-0003b9-PF
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 06:21:01 -0700
In-Reply-To: <18098.54654.108131.864508@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

I have a two example apps that I've been using to test this... Here's
essentially what I'm performing:

Locking App:
[C CODE]
	int _fd = open("/net/share/file", O_CREAT | O_RDWR);
	if ( _fd = -1 ){
		printf("Unable to open file...\n");
		exit 5;
	}

	struct flock fl;
	fl.l_type 	= F_WRLCK
	fl.l_start 	= 0;
	fl.l_whence = SEEK_SET;
	fl.l_len 	= 0;
	fl.l_pid	= getpid();

	if( fnctl(_fd, F_SETLK, $fl) == -1 ) {
	  printf("Unable to lock file\n");
	  close(_fd);
        exit 6;
	}

	for(;;){}
[/C CODE]

Testing App:
[C CODE]
	int _fd = open("/net/share/file", O_RDONLY);
	if ( _fd = -1 ){
		printf("Unable to open file...\n");
		exit 5;
	}

	struct flock fl = {0,0,0,0,0};

	if( fnctl(_fd, F_GETLK, $fl) == -1 ) {
	  printf("Unable to get lock information...\n");
        close(_fd);
        exit 6;
	}

      close(_fd);
      
      print("/net/share/file :");
	switch (fl.l_type) {
	  case F_WRLCK:
		print("F_WRLCK");
        ...
        ...
	}
[/C CODE]


I've got a bit more there to make it easy to execute, such as passing in
the files I want test via command line, but this is essentially how I'm
testing the locks.  I was unaware of the /proc/lock... 

Either way, this mechanism works with the 2.6.9-32 RHEL4 kernel, however
when updating to the 2.6.22.1 within RHEL4 it does not.  For example if
I lock on COMPUTER1, and then check the lock in a separate process on
COMPUTER1 I get F_WRLCK.  If I lock on COMPUTER1 and the check the lock
on COMPUTER2, I get F_UNLCK.

Then we're back to the other issue though, I don't mind going back to
2.6.9-32 if we can figure out how to cut down on this write delay.  Here
is how I'm testing that part:

Writing app:
[Cpp Code]
	ofstream outfile ("/net/share/test.txt");
	outfile << "test data";
	outfile.close();
[/Cpp Code]

Then on three separate machines I execute the following to watch the
contents of the file:
	watch --interval=0 -d "cat /net/share/text.txt"

Then when executing the app the writes to the file, the writing system
will immediately show the modification, while the other 2 may take
anywhere from 2-60 seconds to see the modification...

Thanks again for any help, and I do appologize for the lack of detail
(yeesh... Should have read though that last one a little bit before I
sent it...)

Jason V. Mock
Software Engineer II
L-3 Communications - Greenville Integrated Systems
Jason.V.Mock@L-3Com.com


-----Original Message-----
From: Neil Brown [mailto:neilb@suse.de] 
Sent: Friday, August 03, 2007 02:13
To: Mock, JV Jason @ IS
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] NFS Caching / Locking

On Thursday August 2, Jason.V.Mock@L-3Com.com wrote:
> We've got a few problems, which I'd like to explain, that we need some

> suggestions on methods of correction.  The first being caching where 
> client machines would see changes to a written file anywhere from 5 to

> 60 seconds later.  The clients are running RHEL4 (2.6.9-32 with 
> nfs-utils 1.0.6 - yea yea... I know... ancient...).  I know that 
> O_DIRECT can help override the caching, however some of the worst 
> effects appear to be with command line calls where we don't have the 
> ability/time to modify how they open files.  Just to try to get 
> another point of data to work with, we've loaded up 2.6.22.1 with 
> nfs-utils
> 1.0.8 (and additionally tried 1.1.0), and we appear to be having less 
> problems except for a few occasional delays with executed commands and

> are not able to view locks on all machines (locks are only visible on 
> the system that locked the file).  We have no problem using either 
> kernel, but we'd love to try to figure out each of these problems.  I 
> read through the NFS.sourceforge.net page the comment that "attribute 
> caching" and "data caching" are two seperate things.  In that context 
> they recommended O_DIRECT to resolve data caching, however is there 
> any kind of flag that we can flip to say do not cache data?  At least
> 2.6.22.1 is some what of an improvement on the caching...  if we could

> just resolve the locking issues... would anyone have suggestions on 
> where to look to correct that?  I don't mind getting the NFS calls 
> themselves and the code if need be...

Could you please give more details on the perceived "locking problem"?

All you say is :
> are not able to view locks on all machines (locks are only visible on 
> the system that locked the file).

What do you mean by "view lock"??  Do you mean look in /proc/locks?
Certainly only the client and the server would be able to see any locks
in /proc/locks.  All other clients wouldn't be able to detect the lock
until they try to claim it.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
