From: Jeff Smith <jeff@atheros.com>
Subject: Re: 2.4.18 knfsd load spikes
Date: Wed, 15 May 2002 14:44:07 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CE2D6A7.64EC2FFF@atheros.com>
References: <Pine.LNX.4.30.0205151421340.19272-100000@whitby.atos-group.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------0508FB851EA251F326591BB5"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.atheros.com ([65.212.155.130] helo=atheros.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1786ZH-0005WW-00
	for <nfs@lists.sourceforge.net>; Wed, 15 May 2002 14:44:19 -0700
To: Ryan Sweet <rsweet@atos-group.nl>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

This is a multi-part message in MIME format.
--------------0508FB851EA251F326591BB5
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Ahhhh... Welcome to my hell.  I'm experiencing something similar but
have no resolution.  Here is the exchange I had with Roger Heflin who
also had a similar problem.  I was hoping this would go away with 2.4,
but your experience leaves me very worried...


"Heflin, Roger A." wrote:

Compile it,
run it with ./slowspeed . 65536 .0002 10

This will write 10 files in a round robbin fashion, it will rewind just
before
it hits 2GB and start over again.   65536 is the block size which should
eliminate any disk head thrash issues.   The .0002 is a sleep time to
use and may not really be sleeping much at all during this test.   

You will need about 20GB (10x2GB per file) to run this test, and the
IO rates will be pretty good for a while and then will slowly start to
drop over the next few hours until things become pretty bad.   It
appears
to work over NFS or on local disk, it does not appear to work if you
decrease the number of files to write to at the same time.

Our machines are 440GX/BX's for the disk nodes with ASUS P2D's,
we have been using the older slower machines for the disk as they
seem to have no real issues until this happens, and then the faster
machines appear to do no better.   The disk nodes have 1GB ram.

I went to eXtreme 3000 controllers and I like them more than the 
LVD scsi controllers (2000,1100), they appear to be less sensitive 
to cabling issues with the copper fiber channel.

                                Roger

> -----Original Message-----
> From: Jeff Smith [SMTP:jeff@atheros.com]
> Sent:  3/ 08/ 2002 12:41 PM
> To:   Heflin, Roger A.
> Subject:      Re: [NFS] IO write rate problem with multiple writers to
> different files
> 
> Is is possible to send me the test as well so that I can verify that
> I'm
> experiencing the same problem?
> 
> Thanks,
> Jeff
> 
> "Heflin, Roger A." wrote:
> > 
> > I am talking to Alan Cox and he seems interested in the problem,
> > I have figured out that running the same job on the local machine
> with
> > multiple writers also kills the IO rate and have a fairly small test
> > job that nicely duplicates the problem.  I will be sending this to
> Alan
> > to see if it occurs on other kernels, and if so if it can be fixed
> on on
> > the
> > other kernel and maybe on the 2.2 series.
> > 
> > I am pretty leary of the 2.4 kernels as 2.2.19 is very very stable
> and
> > I don't know if 2.4 has this kind of stability.
> > 
> >                                 Roger
> > 
> > > -----Original Message-----
> > > From: Jeff Smith [SMTP:jeff@atheros.com]
> > > Sent:  3/ 08/ 2002 10:40 AM
> > > To:   Heflin, Roger A.; Stephen Padnos
> > > Subject:      Re: [NFS] IO write rate problem with multiple
> writers to
> > > different files
> > >
> > > Be comforted that you are not alone.  Every time we go through a
> chip
> > > tapeout, the number of large jobs rises, causing our NFS servers
> to
> > > suddenly fall off a cliff and exhibit the same symptoms (low IO
> rate
> > > plummets and the CPU utilization goes to 100%, all of it taken by
> the
> > > nfsd's).  We are running 2.2.18.
> > >
> > > We've been trying for six months to find a window where we can
> upgrade
> > > to 2.4.X and pray that this resolves the problem, but these are
> > > production server and cannot afford any downtime.
> > >
> > > Let me know if you get any unposted responses.  I posted query a
> few
> > > months back, but no solutions were forthcoming.  I would like to
> feel
> > > confident that whatever we try next will actually resolve the
> problem.
> > >
> > > Jeff
> > >
> > >
> > >
> > > "Heflin, Roger A." wrote:
> > > >
> > > > Any ideas on increasing write IO rates in this situation?
> > > >
> > > > I am running 2.2.19 with the NFS released about the 2.2.19 was
> > > released,
> > > > and
> > > > the IO writes slow down massively when there are multiple write
> > > streams,
> > > > it seems
> > > > to require several files to be being written to a the same time.
> > > The
> > > > same behavior
> > > > is not noticed with only 1 or 2 files being open and being
> written
> > > to.
> > > > For the
> > > > behavior to happen it takes 60+ minutes of sustained IO, the
> buffer
> > > > cache fills
> > > > in the expected 2-4 minutes, and then things look pretty good
> for
> > > quite
> > > > a while
> > > > and around 60 minutes the IO rates start to fall until they hit
> > > about
> > > > 1/4-1/8 of
> > > > the IO rate after the buffercache was filled.   The machines are
> > > being
> > > > run with
> > > > sync exports and sync mounts, but the problem was also observed
> with
> > > > sync
> > > > mounts and async exports.
> > > >
> > > > The NFSd go to useing 60-80% of a dual cpu 600mhz PIII and the
> IO
> > > rate
> > > > falls
> > > > down to around 1.1-1.8 MB/second,  and machine response
> generally
> > > falls
> > > > apart.
> > > > I don't understand why the NFSd are using this sort of cpu to do
> > > this
> > > > low of IO
> > > > rate.
> > > >
> > > > The application is writing the data in 128kb chunks, and the
> duty
> > > cycle
> > > > on
> > > > the disk lights is under 50%.
> > > >
> > > > How does NFS interact with the kernel buffercache and could the
> > > > buffercache
> > > > be causing the problem?
> > > >                                 Roger
> > > >
> > > > _______________________________________________
> > > > NFS maillist  -  NFS@lists.sourceforge.net
> > > > https://lists.sourceforge.net/lists/listinfo/nfs
> > >
> > > --
> > > Jeff Smith                                  Atheros
> Communications,
> > > Inc.
> > > Hardware Manager                            529 Almanor Avenue
> > > (408) 773-5257                              Sunnyvale, CA  94086
> 
> -- 
> Jeff Smith                                  Atheros Communications,
> Inc.
> Hardware Manager                            529 Almanor Avenue
> (408) 773-5257                              Sunnyvale, CA  94086

Ryan Sweet wrote:
> 
> I didn't get any responses to the message below, but I _did_ bite the
> bullet and update the IRIX systems, and now the 64bit filehandle problem
> is solved.
> 
> However, the performance problem is not.  With 2.4.18+xfs1.1, It is
> definitely better (the load spikes to 7 or 8, sometimes 10, instead of 20
> or 30...), but I still get the periods where suddenly the system will
> respond _very_ slowly, cpu is mostly idle, memory is all used, but only
> for cache, the system is not swapping at all, but the load climbs up and
> up.  It then gradually falls back down.  The top processes are usually
> bdflush and kupdated, with kupdated always in the dead wait (DW) state.
> It is basically the same behaviour that we saw with 2.4.[2|5]+xfs1.0.2,
> though not as painful.  The problem usually lasts for 3 or four minutes,
> then subsides.
> 
> The problem seemed to begin around the time we added a few new, really
> fast compute workstations, each of which is periodically doing thousands
> of small writes/reads.  I cannot yet make a direct correlation, however,
> until I can get a decent tcpdump.
> 
> does anyone have any pointers on where to begin looking?  Have other
> people seen this behaviour?
> 
> thanks,
> -Ryan

...

> Ryan Sweet <ryan.sweet@atosorigin.com>
> Atos Origin Engineering Services
> http://www.aoes.nl
> 
> _______________________________________________________________
> 
> Have big pipes? SourceForge.net is looking for download mirrors. We supply
> the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Jeff Smith                                  Atheros Communications, Inc.
Hardware Manager                            529 Almanor Avenue
(408) 773-5257                              Sunnyvale, CA  94086
--------------0508FB851EA251F326591BB5
Content-Type: text/plain; charset=us-ascii;
 name="slowspeed.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="slowspeed.c"

/*                                                                       */
/* Written by Roger Heflin roger.a.heflin@conoco.com rahmrh@cableone.net */ 
/*                                                                       */

/* Simulates an application writting multiple data streams to several    */
/* file to duplicate an application IO issues                            */
/* code tries to note when a write takes alot longer than expected       */
/* and does appear to be able to sometimes detect the bdflush deamon     */
/* under the correct conditions */

/* Quite a bit more error checking could be done at various points but
   is not done */

#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <sys/time.h>
#include <unistd.h>

double my_tod()
{
struct timeval t1;

gettimeofday(&t1,NULL);

return(t1.tv_sec + (double)t1.tv_usec/1e6);
}

int main(int argc,char **argv)
{
char *directory;
int write_size;
char filename[30][256];
int  *writebuffer;
long long num_writes;
long long max_writes;
FILE *fn[30];
int nfiles;
int i;
char hostname1[32];
unsigned long sleep_usec;
double delayt;
double write_time;
double bflush_time;
double start_time,end_time,start_time1,end_time1,start_time2,end_time2;
int cnt;
int num_slowwrite;

num_slowwrite = 0;

setlinebuf(stdout);

if (argc != 5)
  {
  fprintf(stderr,"Usage: %s directory size sleep_time numberoffiles\n",argv[0]);
  fprintf(stderr,"      directory - is the directory to work in\n");
  fprintf(stderr,"      size - is the block size to use for the writes\n");
  fprintf(stderr,"      sleep_time is the sleep time in second to sleep\n");
  fprintf(stderr,"             after writing to all files using really\n");
  fprintf(stderr,"             small numbers below the kernel resolution will not\n");
  fprintf(stderr,"             result in smaller times - decimals are allowed\n");
  fprintf(stderr,"      numberoffiles - number of write streams\n");
  exit(-1);
  }

write_size = atoi(argv[2]);
delayt = atof(argv[3]);
directory=argv[1];
nfiles=atoi(argv[4]);

printf("write size is %d sleep time is %f\n",write_size,delayt);
printf("with %d files\n",nfiles);

sleep_usec = delayt * 1000000;
writebuffer = malloc(write_size+4);

if (writebuffer == 0)
  {
  fprintf(stderr,"Malloc of %d bytes failed - error is %s\n",write_size,strerror(errno));
  exit(-1);
  }
chdir(directory);

for (i=0;i<write_size/4;i++)
  {
  writebuffer[i] = i;
  }
gethostname(hostname1,32);
for (i=0;i<nfiles;i++)
  {
  sprintf(filename[i],"%s/%s_%d.tmp_%d",directory,hostname1,getpid(),i);
  fprintf(stderr,"Using filename %s\n",filename[i]);
  }

/* max number of writes to do before doing a rewind */
/* the 2000 number is basically the max file size - adjusting
   it smaller will allow testing with more files on small disks */
max_writes = 2000*1024*1024 / write_size;
num_writes = 0;
write_time = 0;

for (i=0;i<nfiles;i++)
  {
  fn[i] = fopen(filename[i],"wb");
  if (fn[i] == NULL)
    {
    fprintf(stderr,"Failure opening file %s - error is %s\n",filename[i],strerror(errno));
    exit(-1);
    }
  setvbuf(fn[i],malloc(write_size),_IOFBF,write_size);
  }

cnt = 0;
start_time1 = my_tod();
start_time2 = start_time1;
bflush_time=start_time1;
while (1)
  {
  for (i=0;i<nfiles;i++)
    {
    if ((num_writes%max_writes) == 0)  
      {
      fprintf(stderr,"Rewinding file %d\n",i);
      fseek(fn[i],0,SEEK_SET);
      }
      
    start_time = my_tod();
    if (fwrite(writebuffer,write_size,1,fn[i]) != 1)
      {
      fprintf(stderr,"Error fwrite failure - error was %s\n",strerror(errno));
      exit(-1);
      }
    end_time = my_tod();
    write_time += (end_time - start_time);

    if (i==0)
      num_writes ++; 

    if (end_time-start_time > 1.0)
      {
      num_slowwrite ++;
      } 
    }

  /* Only sleep once per every nfiles writes of write_size */ 

    if (sleep_usec != 0)
      usleep(sleep_usec);

/* Print out a rate every xxx writes for each file*/
  if (cnt == 10)
    {
    end_time1 = my_tod();
    end_time2 = end_time1;
    printf("%s %8.1f secs - last wrt speed %8.2f MB/sec %10.2f GB written %8.2f MB/sec overall average %d slowwrites",
           hostname1,
           (end_time2-start_time2),
           ((cnt*write_size*nfiles) / (end_time1-start_time1))/(1024*1024),
           ((double)num_writes*(double)write_size*nfiles)/(1024*1024*1024),
           (((double)num_writes*(double)write_size*nfiles) / (end_time2-start_time2))/(1024*1024),num_slowwrite); 
    if ( ( end_time1 - start_time1) > 5 ) 
      {
      printf(" Buffer flush %5.2f - last was %f seconds ago\n",end_time1 - start_time1,start_time1 - bflush_time);
      bflush_time = start_time1;
      }
    else
      {
      printf("\n");
      }

    start_time1 = my_tod();
    cnt = 0;
    num_slowwrite = 0;
    }  
     
/*   if (access("QUIT_NOW",F_OK) == 0)
    {
    printf("Average time per write %s %f\n",hostname1,write_time/num_writes);
    for (i=0;i<nfiles;i++)
      fclose(fn[i]);
    exit(0);
    }   */
  cnt ++;
  }

}

--------------0508FB851EA251F326591BB5--


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
